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

/**
 * How long to wait for a decodable first frame before giving up.
 *
 * An HLS playlist that never materialises (SRS has no publisher, so the
 * `.m3u8` 404s) produced an infinite "loading HLS stream…" banner: hls.js
 * retries fatal NETWORK_ERRORs forever and nothing ever marked the tile as
 * failed. Users read that as "still buffering" and waited instead of
 * investigating. Failing closed turns it into an actionable message.
 */
export const HLS_START_TIMEOUT_MS = 20_000;

export interface HlsPlayerSession {
  /** Stops playback, detaches the video element, and releases resources. */
  close(): void;
}

export interface HlsPlayerCallbacks {
  /** Called when the first frame is decoded and presented. */
  onRendering?(): void;
  /** Called on an unrecoverable HLS error, or when the start timeout expires. */
  onError?(message: string): void;
}

/**
 * Attaches an HLS stream to a `<video>` element via hls.js.
 *
 * Returns a session handle whose `close()` detaches the stream. If the
 * browser supports HLS natively (Safari, iOS), the native `<video src>`
 * path is used instead — no hls.js instance is created.
 *
 * Fails closed: if no frame is rendered within `HLS_START_TIMEOUT_MS`,
 * `onError` fires once and playback stops retrying.
 */
export function startHlsPlayer(
  videoEl: HTMLVideoElement,
  hlsUrl: string,
  callbacks: HlsPlayerCallbacks = {},
): HlsPlayerSession {
  let settled = false;
  let timer: ReturnType<typeof setTimeout> | undefined;

  const rendered = () => {
    if (settled) return;
    settled = true;
    if (timer !== undefined) clearTimeout(timer);
    callbacks.onRendering?.();
  };

  const failed = (message: string) => {
    if (settled) return;
    settled = true;
    if (timer !== undefined) clearTimeout(timer);
    callbacks.onError?.(message);
  };

  // Arm the timeout before any playback is attempted, so every failure
  // mode (404 manifest, silent stall, unsupported browser) converges on
  // the same terminal state.
  timer = setTimeout(() => {
    failed(
      `HLS stream did not start within ${Math.round(
        HLS_START_TIMEOUT_MS / 1000,
      )}s — the playlist may not exist (no publisher on this camera)`,
    );
  }, HLS_START_TIMEOUT_MS);

  // Safari / iOS: native HLS via the <video> element.
  if (videoEl.canPlayType("application/vnd.apple.mpegurl")) {
    videoEl.src = hlsUrl;
    videoEl.play().catch(() => undefined);
    videoEl.addEventListener("playing", rendered, { once: true });
    return {
      close() {
        if (timer !== undefined) clearTimeout(timer);
        videoEl.src = "";
        videoEl.load();
      },
    };
  }

  // Chrome / Firefox / Edge: hls.js MSE-based playback.
  if (!Hls.isSupported()) {
    failed("HLS playback not supported in this browser");
    return { close() {} };
  }

  const hls = new Hls({
    // Low-latency tuning: keep the segment buffer small so glass-to-glass
    // stays near the minimum (3 segments × segment duration + network).
    liveSyncDurationCount: 2,
    liveMaxLatencyDurationCount: 4,
    // Retry on transient network errors (common on mobile CGNAT). Bounded
    // so a permanent 404 surfaces instead of retrying forever.
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
      rendered();
    }
  });

  hls.on(Hls.Events.ERROR, (_event, data) => {
    if (!data.fatal) return;

    switch (data.type) {
      case Hls.ErrorTypes.NETWORK_ERROR:
        // A 404 on the manifest is terminal — retrying cannot help, and
        // doing so is what hid the failure behind an endless spinner.
        if (
          data.details === Hls.ErrorDetails.MANIFEST_LOAD_ERROR ||
          data.details === Hls.ErrorDetails.MANIFEST_LOAD_TIMEOUT
        ) {
          failed(`HLS playlist unavailable (${data.details})`);
          hls.destroy();
          return;
        }
        hls.startLoad();
        break;
      case Hls.ErrorTypes.MEDIA_ERROR:
        hls.recoverMediaError();
        break;
      default:
        failed(`HLS fatal error: ${data.type} — ${data.details}`);
        hls.destroy();
        break;
    }
  });

  return {
    close() {
      if (timer !== undefined) clearTimeout(timer);
      hls.destroy();
      videoEl.src = "";
      videoEl.load();
    },
  };
}
