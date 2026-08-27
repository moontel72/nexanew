// Minimal WHEP (WebRTC HTTP Egress Protocol) viewer helper.
//
// Post a recvonly SDP offer to the media engine, set the returned answer,
// and attach the remote tracks to a <video> element.

import { env } from "../utils";
import { getToken } from "../auth/authStore";

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
    const timeout = setTimeout(done, 2500);
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
  const stream = new MediaStream();
  pc.ontrack = (event) => stream.addTrack(event.track);
  opts.videoEl.srcObject = stream;

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  await waitIceComplete(pc);

  // The SSO JWT authenticates the viewer WHEP POST as well.
  const token = getToken();
  if (!token) {
    pc.close();
    throw new Error("WHEP watch failed: not authenticated");
  }

  const res = await fetch(opts.watchUrl, {
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
