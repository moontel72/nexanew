//! PLI (Picture Loss Indication) forwarding broker.
//!
//! Design: two lightweight RTCP interceptors around one shared broker.
//!
//! - [`PliWriterInterceptor`] is installed on the **WHIP (publisher)**
//!   API: before each RTCP write it drains the broker's pending keyframe
//!   requests and sends them as PLI packets upstream to the publisher.
//! - [`PliReaderInterceptor`] is installed on the **WHEP (viewer)** API:
//!   it inspects inbound RTCP for viewer PLIs and converts them (through
//!   the viewer-facing SSRC → publisher SSRC map) into pending requests.
//!
//! The SFU also requests a keyframe directly whenever a viewer subscribes
//! to a camera, so new viewers receive an IDR immediately instead of
//! waiting for the publisher's next keyframe interval.
//!
//! NACK retransmission needs no custom code: webrtc-rs 0.17's default
//! interceptor set already registers the NACK generator + responder with
//! `nack pli` feedback negotiated in the SDP.

use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use dashmap::DashMap;
use webrtc::interceptor::stream_info::StreamInfo;
use webrtc::interceptor::{
    Attributes, Interceptor, InterceptorBuilder, RTCPReader, RTCPReaderFn, RTCPWriter,
    RTCPWriterFn, RTPReader, RTPWriter,
};
use webrtc::rtcp::payload_feedbacks::picture_loss_indication::PictureLossIndication;

/// Shared keyframe-request state between the writer and reader sides.
pub struct PliBroker {
    /// publisher ssrc → pending PLI request count.
    pending: Arc<DashMap<u32, Arc<AtomicU64>>>,
    /// SFU outbound (viewer-facing) ssrc → publisher inbound ssrc.
    viewer_map: Arc<DashMap<u32, u32>>,
}

impl PliBroker {
    pub fn new() -> Arc<Self> {
        Arc::new(Self {
            pending: Arc::new(DashMap::new()),
            viewer_map: Arc::new(DashMap::new()),
        })
    }

    /// The SFU wants a keyframe for a publisher SSRC.
    pub fn request_keyframe(&self, publisher_ssrc: u32) {
        self.pending
            .entry(publisher_ssrc)
            .or_insert_with(|| Arc::new(AtomicU64::new(0)))
            .fetch_add(1, Ordering::Relaxed);
    }

    /// Registers the viewer-facing SSRC → publisher SSRC mapping.
    pub fn register_viewer(&self, viewer_ssrc: u32, publisher_ssrc: u32) {
        self.viewer_map.insert(viewer_ssrc, publisher_ssrc);
    }

    /// Removes a closed viewer's mapping.
    pub fn unregister_viewer(&self, viewer_ssrc: u32) {
        self.viewer_map.remove(&viewer_ssrc);
    }

    /// Drains pending requests into PLI packets (writer side).
    fn take_pending(&self) -> Vec<Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>> {
        let mut out = Vec::new();
        for entry in self.pending.iter() {
            let ssrc = *entry.key();
            let count = entry.value().swap(0, Ordering::Relaxed);
            if count > 0 {
                out.push(Box::new(PictureLossIndication {
                    sender_ssrc: 0,
                    media_ssrc: ssrc,
                })
                    as Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>);
            }
        }
        out
    }

    /// Observes RTCP packets for PLIs (reader side).
    fn observe(&self, pkts: &[Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>]) {
        for pkt in pkts {
            if let Some(pli) = pkt.as_any().downcast_ref::<PictureLossIndication>() {
                let target = self.viewer_map.get(&pli.media_ssrc).map(|v| *v.value());
                if let Some(target) = target {
                    self.request_keyframe(target);
                }
            }
        }
    }
}

/// Installed on the WHIP API: injects pending PLIs into outbound RTCP.
pub struct PliWriterInterceptor {
    broker: Arc<PliBroker>,
}

/// Installed on the WHEP API: observes inbound RTCP for PLIs.
pub struct PliReaderInterceptor {
    broker: Arc<PliBroker>,
}

/// Builder for the writer interceptor.
pub struct PliWriterBuilder {
    broker: Arc<PliBroker>,
}

/// Builder for the reader interceptor.
pub struct PliReaderBuilder {
    broker: Arc<PliBroker>,
}

impl PliBroker {
    pub fn writer_builder(self: &Arc<Self>) -> PliWriterBuilder {
        PliWriterBuilder {
            broker: Arc::clone(self),
        }
    }

    pub fn reader_builder(self: &Arc<Self>) -> PliReaderBuilder {
        PliReaderBuilder {
            broker: Arc::clone(self),
        }
    }
}

impl InterceptorBuilder for PliWriterBuilder {
    fn build(
        &self,
        _id: &str,
    ) -> std::result::Result<Arc<dyn Interceptor + Send + Sync>, webrtc::interceptor::Error> {
        Ok(Arc::new(PliWriterInterceptor {
            broker: Arc::clone(&self.broker),
        }))
    }
}

impl InterceptorBuilder for PliReaderBuilder {
    fn build(
        &self,
        _id: &str,
    ) -> std::result::Result<Arc<dyn Interceptor + Send + Sync>, webrtc::interceptor::Error> {
        Ok(Arc::new(PliReaderInterceptor {
            broker: Arc::clone(&self.broker),
        }))
    }
}

#[async_trait::async_trait]
impl Interceptor for PliWriterInterceptor {
    async fn bind_rtcp_writer(
        &self,
        writer: Arc<dyn RTCPWriter + Send + Sync>,
    ) -> Arc<dyn RTCPWriter + Send + Sync> {
        let broker = Arc::clone(&self.broker);
        Arc::new(RTCPWriterFn(Box::new(
            move |pkts: &[Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>],
                  attributes: &Attributes| {
                let writer = Arc::clone(&writer);
                let broker = Arc::clone(&broker);
                // The wrapper future must be `Send + Sync`; the inner
                // writer's future is only `Send`, so run it as an owned
                // spawned task and await the JoinHandle (which is Sync).
                let owned_pkts: Vec<Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>> =
                    pkts.iter().map(|p| p.cloned()).collect();
                let owned_attrs = attributes.clone();
                Box::pin(async move {
                    let handle = tokio::spawn(async move {
                        // Forward the original batch first.
                        let n = writer.write(&owned_pkts, &owned_attrs).await?;
                        // Then inject any pending keyframe requests.
                        let plis = broker.take_pending();
                        if !plis.is_empty() {
                            let _ = writer.write(&plis, &owned_attrs).await;
                        }
                        Ok(n)
                    });
                    handle
                        .await
                        .map_err(|e| webrtc::interceptor::Error::Other(e.to_string()))?
                })
            },
        )))
    }

    async fn bind_rtcp_reader(
        &self,
        reader: Arc<dyn RTCPReader + Send + Sync>,
    ) -> Arc<dyn RTCPReader + Send + Sync> {
        reader
    }

    async fn bind_local_stream(
        &self,
        _info: &StreamInfo,
        writer: Arc<dyn RTPWriter + Send + Sync>,
    ) -> Arc<dyn RTPWriter + Send + Sync> {
        writer
    }

    async fn unbind_local_stream(&self, _info: &StreamInfo) {}

    async fn bind_remote_stream(
        &self,
        _info: &StreamInfo,
        reader: Arc<dyn RTPReader + Send + Sync>,
    ) -> Arc<dyn RTPReader + Send + Sync> {
        reader
    }

    async fn unbind_remote_stream(&self, _info: &StreamInfo) {}

    async fn close(&self) -> std::result::Result<(), webrtc::interceptor::Error> {
        Ok(())
    }
}

#[async_trait::async_trait]
impl Interceptor for PliReaderInterceptor {
    async fn bind_rtcp_reader(
        &self,
        reader: Arc<dyn RTCPReader + Send + Sync>,
    ) -> Arc<dyn RTCPReader + Send + Sync> {
        let broker = Arc::clone(&self.broker);
        Arc::new(RTCPReaderFn(Box::new(
            move |buf: &mut [u8], attributes: &Attributes| {
                let reader = Arc::clone(&reader);
                let broker = Arc::clone(&broker);
                // See the writer hook: owned inputs + spawn keep the
                // wrapper future `Send + Sync`. The buffer is input-only
                // (the caller reuses it as scratch for the next read), so
                // nothing is written back.
                let mut owned_buf = buf.to_vec();
                let owned_attrs = attributes.clone();
                Box::pin(async move {
                    let handle = tokio::spawn(async move {
                        let (pkts, attrs) = reader.read(&mut owned_buf, &owned_attrs).await?;
                        broker.observe(&pkts);
                        Ok::<
                            (
                                Vec<Box<dyn webrtc::rtcp::packet::Packet + Send + Sync>>,
                                Attributes,
                            ),
                            webrtc::interceptor::Error,
                        >((pkts, attrs))
                    });
                    let (pkts, attrs) = handle
                        .await
                        .map_err(|e| webrtc::interceptor::Error::Other(e.to_string()))??;
                    Ok((pkts, attrs))
                })
            },
        )))
    }

    async fn bind_rtcp_writer(
        &self,
        writer: Arc<dyn RTCPWriter + Send + Sync>,
    ) -> Arc<dyn RTCPWriter + Send + Sync> {
        writer
    }

    async fn bind_local_stream(
        &self,
        _info: &StreamInfo,
        writer: Arc<dyn RTPWriter + Send + Sync>,
    ) -> Arc<dyn RTPWriter + Send + Sync> {
        writer
    }

    async fn unbind_local_stream(&self, _info: &StreamInfo) {}

    async fn bind_remote_stream(
        &self,
        _info: &StreamInfo,
        reader: Arc<dyn RTPReader + Send + Sync>,
    ) -> Arc<dyn RTPReader + Send + Sync> {
        reader
    }

    async fn unbind_remote_stream(&self, _info: &StreamInfo) {}

    async fn close(&self) -> std::result::Result<(), webrtc::interceptor::Error> {
        Ok(())
    }
}
