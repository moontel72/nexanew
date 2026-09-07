# ── WebRTC native classes must not be obfuscated ──
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# ── OkHttp ──
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# ── Kotlin coroutines ──
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# ── Keep native method names (JNI) ──
-keepclasseswithmembernames class * {
    native <methods>;
}
