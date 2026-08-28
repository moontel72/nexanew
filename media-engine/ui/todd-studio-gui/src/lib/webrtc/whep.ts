// Minimal WHEP (WebRTC HTTP Egress Protocol) viewer helper.
//
// Post a recvonly SDP offer to the media engine, set the returned answer,
// and attach the remote tracks to a <video> element.

import { env } from "../utils";
import { getToken, refreshToken } from "../auth/authStore";

export interface WhepSession {
  pc: RTCPeerConnection;
  close(): void;
}

/** WHEP POST failure carrying the HTTP status so callers can decide
 * whether to retry (409 = camera not live yet, 5xx = engine hiccup) or
 * surface a permanent error (401/403/404). */
export class WhepWatchError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "WhepWatchError";
  }
}

/** True when a failed watch may succeed after a short retry. */
export function isRetryableWatchError(error: unknown): boolean {
  if (error instanceof WhepWatchError) {
    return error.status === 409 || error.status === 0 || error.status >= 500;
  }
  return error instanceof TypeError; // fetch network failure
}

async function waitIceComplete(pc: RTCPeerConnection): Promise<void> {
  if (pc.iceGatheringState === "complete") return;
  await new Promise<void>((resolve) => {
    // Same 10s bound as the broadcaster app: STUN discovery behind NAT
    // can take a few seconds. A too-short cap sends the WHEP offer with
    // host-only candidates and the engine's answer can never reach us.
    const timeout = setTimeout(done, 10000);
    function done() {
      clearTimeout(timeout);
      pc.removeEventListener("icegatheringstatechange", onState);
      resolve();
    }
    function onState() {
      if (pc.iceGatheringState === "complete") done();
    }
    pc.addEventListener("icegatheringstatechange", onState);
  });
}

export async function startWhepWatch(opts: {
  watchUrl: string;
  videoEl: HTMLVideoElement;
}): Promise<WhepSession> {
  const iceServers: RTCIceServer[] = [];
  // Same fallback as the broadcaster app: an empty env STUN leaves the
  // viewer with host-only candidates, which can fail behind strict NATs.
  iceServers.push({ urls: env.stunUrl || "stun:stun.l.google.com:19302" });
  if (env.turnUrl) iceServers.push({ urls: env.turnUrl });

  const pc = new RTCPeerConnection({ iceServers });
  pc.addTransceiver("video", { direction: "recvonly" });
  pc.addTransceiver("audio", { direction: "recvonly" });

  // Bind the track listener and the media element *before* the SDP
  // exchange: the answer may arrive while ICE is still warming, and a
  // track can fire as soon as the remote description is applied. Binding
  // first guarantees the HTML5 <video> always receives the stream.
  //
  // Autoplay hardening: set muted/playsinline as element properties (not
  // just attributes) and re-issue play() from the ontrack handler — the
  // track frequently arrives AFTER the first play() call, and a video
  // that was playing an empty stream can stay black forever.
  const fallbackStream = new MediaStream();
  opts.videoEl.muted = true;
  opts.videoEl.setAttribute("muted", "");
  opts.videoEl.setAttribute("playsinline", "");
  opts.videoEl.autoplay = true;
  opts.videoEl.srcObject = fallbackStream;
  pc.ontrack = (event) => {
    // Prefer the incoming stream object; fall back to appending the raw
    // track (some browsers omit event.streams).
    if (event.streams.length > 0) {
      opts.videoEl.srcObject = event.streams[0];
    } else {
      fallbackStream.addTrack(event.track);
    }
    opts.videoEl.play().catch(() => undefined);
  };

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  await waitIceComplete(pc);

  // The SSO JWT authenticates the viewer WHEP POST as well.
  const token = getToken();
  if (!token) {
    pc.close();
    throw new Error("WHEP watch failed: not authenticated");
  }

  // 401 = the SSO JWT expired (15-min TTL). Refresh it once and retry —
  // the tile must self-heal instead of pinning the error overlay until a
  // manual reload.
  let res = await postWatch(opts.watchUrl, token, pc);
  if (res.status === 401) {
    const fresh = await refreshToken();
    if (fresh) {
      res = await postWatch(opts.watchUrl, fresh, pc);
    }
  }
  if (!res.ok) {
    pc.close();
    throw new WhepWatchError(`WHEP watch failed (${res.status})`, res.status);
  }
  const answerSdp = await res.text();
  await pc.setRemoteDescription({ type: "answer", sdp: answerSdp });
  await opts.videoEl.play().catch(() => undefined);

  return {
    pc,
    close() {
      pc.close();
      opts.videoEl.srcObject = null;
    },
  };
}

/** Posts the WHEP offer with the given bearer token; network errors map
 * to status 0. The PC is left open so a 401 refresh can retry with the
 * same offer. */
async function postWatch(
  watchUrl: string,
  token: string,
  pc: RTCPeerConnection,
): Promise<Response> {
  return fetch(watchUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/sdp",
      Authorization: `Bearer ${token}`,
    },
    body: pc.localDescription?.sdp ?? "",
  }).catch(() => {
    pc.close();
    throw new WhepWatchError("WHEP watch failed: network error", 0);
  });
}
