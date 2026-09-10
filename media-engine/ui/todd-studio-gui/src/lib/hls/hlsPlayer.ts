// Thin wrapper around hls.js for HLS camera tiles in Todd Studio.
//
// When a camera's source_kind is "rtmp" (or any HLS-delivered source),
// the viewer tile renders an HLS <video> element instead of a WHEP
// RTCPeerConnection. The HLS feed comes from the existing SRS HLS
// output (cricket.traceodd.com/hls/live/{stream_key}.m3u8), giving
// 4–10 s glass-to-glass latency with zero engine changes.
//
// Rollback: remove this file and the HLS mode in MultiviewTile.tsx —
// all cameras revert to WHEP-only.

import Hls from "hls.js";

export interface HlsPlayerSession {
  /** Stops playback, detaches the video element, and releases resources. */
  close(): void;
}

export interface HlsPlayerCallbacks {
  /** Called when the first frame is decoded and presented. */
  onRendering?(): void;
  /** Called on an unrecoverable HLS error. */
  onError?(message: string): void;
}

/**
 * Attaches an HLS stream to a `<video>` element via hls.js.
 *
 * Returns a session handle whose `close()` detaches the stream. If the
 * browser supports HLS natively (Safari, iOS), the native `<video src>`
 * path is used instead — no hls.js instance is created.
 */
export function startHlsPlayer(
  videoEl: HTMLVideoElement,
  hlsUrl: string,
  callbacks: HlsPlayerCallbacks = {},
): HlsPlayerSession {
  // Safari / iOS: native HLS via the <video> element.
  if (videoEl.canPlayType("application/vnd.apple.mpegurl")) {
    videoEl.src = hlsUrl;
    videoEl.play().catch(() => undefined);
    videoEl.addEventListener("playing", () => callbacks.onRendering?.(), {
      once: true,
    });
    return {
      close() {
        videoEl.src = "";
        videoEl.load();
      },
    };
  }

  // Chrome / Firefox / Edge: hls.js MSE-based playback.
  if (!Hls.isSupported()) {
    callbacks.onError?.("HLS playback not supported in this browser");
    return { close() {} };
  }

  const hls = new Hls({
    // Low-latency tuning: keep the segment buffer small so glass-to-glass
    // stays near the minimum (3 segments × segment duration + network).
    liveSyncDurationCount: 2,
    liveMaxLatencyDurationCount: 4,
    // Retry on transient network errors (common on mobile CGNAT).
    manifestLoadingMaxRetry: 3,
    manifestLoadingRetryDelay: 1000,
    levelLoadingMaxRetry: 3,
    levelLoadingRetryDelay: 1000,
  });

  hls.loadSource(hlsUrl);
  hls.attachMedia(videoEl);

  hls.on(Hls.Events.MANIFEST_PARSED, () => {
    videoEl.play().catch(() => undefined);
  });

  hls.on(Hls.Events.FRAG_CHANGED, () => {
    // First decoded frame: the video element now has dimensions.
    if (videoEl.videoWidth > 0) {
      callbacks.onRendering?.();
    }
  });

  hls.on(Hls.Events.ERROR, (_event, data) => {
    if (data.fatal) {
      switch (data.type) {
        case Hls.ErrorTypes.NETWORK_ERROR:
          hls.startLoad();
          break;
        case Hls.ErrorTypes.MEDIA_ERROR:
          hls.recoverMediaError();
          break;
        default:
          callbacks.onError?.(
            `HLS fatal error: ${data.type} — ${data.details}`,
          );
          hls.destroy();
          break;
      }
    }
  });

  return {
    close() {
      hls.destroy();
      videoEl.src = "";
      videoEl.load();
    },
  };
}
