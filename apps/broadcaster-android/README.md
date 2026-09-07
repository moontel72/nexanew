# Todd Broadcaster (Native Android)

Native Android Kotlin implementation of the Todd Broadcaster app, replacing the Flutter-based broadcaster for stable, Larix-like broadcasting performance on low-end devices (Samsung Galaxy J-series and similar).

## Architecture

```
app/src/main/java/com/todd/broadcaster/
├── MainActivity.kt              — UI + broadcast lifecycle + watchdog
├── BroadcasterApplication.kt    — App initialization
├── whip/
│   ├── WhipClient.kt           — HTTP WHIP signaling (POST SDP offer → 201 answer)
│   └── WhipSession.kt          — Session state + result types
├── media/
│   ├── BroadcasterEngine.kt    — WebRTC PeerConnection + Camera2 + Audio
│   └── EncoderConfig.kt        — Device-tuned H264 encoder parameters
└── telemetry/
    ├── DeviceTelemetry.kt       — WebSocket health push (5s interval)
    └── DeviceHealth.kt          — Health snapshot model
```

## Key Differences from Flutter App

| Feature | Flutter (old) | Native (new) |
|---------|---------------|--------------|
| Encoder control | `flutter_webrtc` plugin (3 abstraction layers) | Direct `MediaCodec` via WebRTC Java API |
| Codec config | Limited to plugin defaults | Explicit H264 Baseline/L3.1/CBR/2s-keyframe |
| ICE gathering | Trickle (can miss candidates) | Full-gather (non-trickle, matching engine) |
| Watchdog | One-shot timer, gives up after 1 check | Periodic 15s, auto-restart up to 3 times |
| Device tuning | None | Samsung J-series detection, adaptive bitrate |

## Build Requirements

- JDK 17
- Android SDK API 34 + build-tools 34.0.0
- Android NDK 27.x (for future C++ JNI if needed)
- CMake 3.22.1+

## Build & Run

```bash
# Generate Gradle wrapper (first time only)
gradle wrapper --gradle-version 8.5

# Debug build
./gradlew assembleDebug

# Install on connected device
./gradlew installDebug
```

## WHIP Protocol Flow

1. Create `PeerConnection` with ICE servers (STUN/TURN)
2. Add audio + video tracks (sendonly)
3. Create SDP offer → wait for full ICE gathering
4. `POST /api/v1/whip/ingest/{room}/{camera}?token={token}` with SDP body
5. Parse 201 response: SDP answer + `Location` header
6. Set remote description (answer) → media flows
7. On stop: `DELETE {Location}` to tear down server-side session

## Encoder Tuning for Low-End Devices

The `EncoderConfig` object provides explicit MediaCodec parameters:
- **Profile**: Constrained Baseline (maximum decoder compatibility)
- **Level**: 3.1 (720p@30fps ceiling)
- **Keyframe interval**: 2 seconds (fast WHEP viewer join)
- **Bitrate mode**: CBR (constant — avoids VBR spikes that overwhelm low-end encoders)
- **Color format**: Surface input (zero-copy hardware path)

## License

Proprietary — NexaTrace System
