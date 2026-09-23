// Todd WHEP viewer — minimal WebRTC (WHEP) playback client.
//
// Same contract as the director app's client
// (media-engine/ui/todd-studio-gui/src/lib/webrtc/whep.ts), reduced to plain
// JS so the public web page can load it as a vendored asset with no build
// step — the same approach the HLS player already uses for hls.js.
//
// Usage:
//   const session = ToddWhep.watch({
//     url: '/whep/watch/<room>/<camera>',   // same-origin, proxied by nginx
//     token: '<viewer JWT>',
//     video: videoElement,
//     iceServers: [...],
//     onState: (state, detail) => {},       // 'watching' | 'retrying' | 'failed'
//   });
//   session.close();
//
// Why this exists: HLS is segmented by construction, so it is seconds behind
// live at best and stalls whenever a segment is slow (SRS only cuts on source
// keyframes in remux mode). WebRTC has no segments and no playlist, so the
// same camera plays sub-second — the way Todd Studio already watches it.
(function (global) {
  "use strict";

  var RETRY_DELAY_MS = 1500;
  var MAX_ATTEMPTS = 20;
  /** No decoded frame for this long => restart the watch (fresh keyframe PLI). */
  var BLACK_FRAME_TIMEOUT_MS = 10000;
  /** STUN discovery behind NAT can take a few seconds; too short a cap sends
   * host-only candidates and the answer can never reach us. */
  var ICE_GATHER_TIMEOUT_MS = 10000;

  function WhepError(message, status) {
    var error = new Error(message);
    error.name = "WhepWatchError";
    error.status = status;
    return error;
  }

  function isRetryable(status) {
    // 409 = the camera is not live yet; 5xx = engine hiccup; 0 = network error.
    return status === 409 || status === 0 || status >= 500;
  }

  function waitIceComplete(pc) {
    if (pc.iceGatheringState === "complete") {
      return Promise.resolve();
    }

    return new Promise(function (resolve) {
      var timer = setTimeout(done, ICE_GATHER_TIMEOUT_MS);

      function done() {
        clearTimeout(timer);
        pc.removeEventListener("icegatheringstatechange", onState);
        resolve();
      }

      function onState() {
        if (pc.iceGatheringState === "complete") {
          done();
        }
      }

      pc.addEventListener("icegatheringstatechange", onState);
    });
  }

  /**
   * The engine answers with a `Location` header for the session resource. It
   * may be relative (`/api/v1/whep/session/<id>`) or absolute against the
   * engine's own base URL, which a browser cannot reach. Take just the id and
   * rebuild the URL under the same prefix the watch POST used, so teardown
   * always reaches the engine through the public proxy.
   */
  function sessionUrlFrom(location, watchUrl) {
    if (!location) {
      return null;
    }

    var id = String(location).split("?")[0].replace(/\/+$/, "").split("/").pop();
    if (!id) {
      return null;
    }

    var base = String(watchUrl).replace(/\/watch\/[^/]+\/[^/?]+.*$/, "");
    return base + "/session/" + encodeURIComponent(id);
  }

  /**
   * One watch attempt: attach the element, open the peer connection, post the
   * offer, apply the answer. Rejects with WhepError carrying the HTTP status.
   */
  function once(opts) {
    var video = opts.video;
    var pc = new RTCPeerConnection({ iceServers: opts.iceServers || [] });
    var closed = false;

    pc.addTransceiver("video", { direction: "recvonly" });
    pc.addTransceiver("audio", { direction: "recvonly" });

    // Bind the track handler and the media element *before* the SDP exchange:
    // the answer can arrive while ICE is still warming, and a track fires as
    // soon as the remote description is applied. A video element that played an
    // empty stream first tends to stay black forever.
    var remoteStream = typeof MediaStream === "function" ? new MediaStream() : null;
    video.muted = true;
    video.defaultMuted = true;
    video.setAttribute("muted", "");
    video.setAttribute("playsinline", "");
    video.autoplay = true;
    if (remoteStream) {
      video.srcObject = remoteStream;
    }

    pc.ontrack = function (event) {
      if (event.streams && event.streams[0]) {
        video.srcObject = event.streams[0];
      } else if (remoteStream) {
        var known = remoteStream.getTracks().some(function (track) {
          return track.id === event.track.id;
        });
        if (!known) {
          remoteStream.addTrack(event.track);
        }
      }

      var played = video.play();
      if (played && played.catch) {
        played.catch(function () {});
      }
    };

    return Promise.resolve()
      .then(function () {
        return pc.createOffer();
      })
      .then(function (offer) {
        return pc.setLocalDescription(offer);
      })
      .then(function () {
        return waitIceComplete(pc);
      })
      .then(function () {
        return fetch(opts.url, {
          method: "POST",
          headers: {
            "Content-Type": "application/sdp",
            Authorization: "Bearer " + opts.token,
          },
          body: (pc.localDescription && pc.localDescription.sdp) || "",
        });
      })
      .catch(function (error) {
        pc.close();
        closed = true;
        if (error && error.name === "WhepWatchError") {
          throw error;
        }
        throw WhepError("WHEP watch failed: network error", 0);
      })
      .then(function (response) {
        if (!response.ok) {
          var status = response.status;
          pc.close();
          closed = true;
          throw WhepError("WHEP watch failed (" + status + ")", status);
        }

        var sessionUrl = sessionUrlFrom(response.headers.get("location"), opts.url);
        return response.text().then(function (answer) {
          return pc.setRemoteDescription({ type: "answer", sdp: answer }).then(function () {
            var played = video.play();
            if (played && played.catch) {
              played.catch(function () {});
            }

            return {
              sessionUrl: sessionUrl,
              close: function () {
                if (closed) {
                  return;
                }
                closed = true;
                try {
                  pc.close();
                } catch (e) {
                  /* already closed */
                }
                video.srcObject = null;
                if (sessionUrl) {
                  // Best effort: frees the engine slot immediately instead of
                  // waiting out its disconnected grace.
                  fetch(sessionUrl, {
                    method: "DELETE",
                    headers: { Authorization: "Bearer " + opts.token },
                  }).catch(function () {});
                }
              },
            };
          });
        });
      });
  }

  /**
   * Watches until `session.close()`. Retries transient failures and restarts
   * the session when no frame is decoded, reporting through `onState`.
   */
  function watch(opts) {
    var video = opts.video;
    var onState = opts.onState || function () {};
    var current = null;
    var cancelled = false;
    var blackFrameTimer = null;

    function stopBlackFrameWatch() {
      if (blackFrameTimer) {
        clearInterval(blackFrameTimer);
        blackFrameTimer = null;
      }
    }

    function startBlackFrameWatch() {
      stopBlackFrameWatch();
      blackFrameTimer = setInterval(function () {
        if (cancelled) {
          return;
        }
        // `connected` alone only proves the session and the RTP path are up;
        // the real render signal is decoded frames on the element.
        if (video.videoWidth === 0) {
          onState("retrying", "no decoded frames");
          attempt(0, true);
        }
      }, BLACK_FRAME_TIMEOUT_MS);
    }

    function attempt(count, fromWatchdog) {
      if (cancelled) {
        return;
      }

      if (current) {
        current.close();
        current = null;
      }
      if (fromWatchdog) {
        stopBlackFrameWatch();
      }

      once(opts).then(
        function (session) {
          if (cancelled) {
            session.close();
            return;
          }
          current = session;
          onState("watching", null);
          startBlackFrameWatch();
        },
        function (error) {
          if (cancelled) {
            return;
          }

          var status = error && typeof error.status === "number" ? error.status : 0;
          if (isRetryable(status) && count < MAX_ATTEMPTS) {
            onState("retrying", (error && error.message) || "retrying");
            setTimeout(function () {
              attempt(count + 1, false);
            }, RETRY_DELAY_MS);
            return;
          }

          onState("failed", (error && error.message) || "WHEP watch failed");
        }
      );
    }

    attempt(0, false);

    return {
      close: function () {
        cancelled = true;
        stopBlackFrameWatch();
        if (current) {
          current.close();
          current = null;
        }
      },
    };
  }

  global.ToddWhep = { watch: watch, isRetryable: isRetryable };
})(typeof window !== "undefined" ? window : this);
