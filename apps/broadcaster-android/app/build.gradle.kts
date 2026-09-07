import java.io.File

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.todd.broadcaster"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.todd.broadcaster"
        minSdk = 24          // Samsung Galaxy J-series (Android 7.0+)
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    // ── Release signing ─────────────────────────────────────────────
    // CI provides a persistent keystore via environment variables so that
    // cameramen can update the app in place. When those variables are absent
    // (local builds / first CI run) the release build falls back to the debug
    // key so `assembleRelease` still yields an installable app-release.apk.
    signingConfigs {
        create("release") {
            val storeFilePath = System.getenv("BROADCASTER_KEYSTORE_PATH")
            if (!storeFilePath.isNullOrBlank()) {
                val store = File(storeFilePath)
                if (store.exists()) {
                    storeFile = store
                    storePassword = System.getenv("BROADCASTER_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("BROADCASTER_KEY_ALIAS")
                    keyPassword = System.getenv("BROADCASTER_KEY_PASSWORD")
                }
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            val releaseSigning = signingConfigs.getByName("release")
            signingConfig = if (releaseSigning.storeFile != null) {
                releaseSigning
            } else {
                signingConfigs.getByName("debug")
            }
        }
        debug {
            isMinifyEnabled = false
            applicationIdSuffix = ".debug"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
        buildConfig = true   // AGP 8.x: BuildConfig is opt-in; needed for BuildConfig.VERSION_NAME
    }
}

dependencies {
    // ── WebRTC native (libwebrtc Android build) ──
    // Stream's pre-compiled WebRTC library — provides the standard org.webrtc.*
    // package (PeerConnectionFactory, Camera2Capturer, HardwareVideoEncoderFactory,
    // SurfaceViewRenderer, AudioDeviceModule) with direct access to MediaCodec
    // + libwebrtc C++. Available on Maven Central, actively maintained.
    implementation("io.getstream:stream-webrtc-android:1.3.10")

    // ── HTTP client for WHIP signaling ──
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // ── Kotlin coroutines ──
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // ── AndroidX ──
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")

    // ── Camera2 (used via WebRTC's Camera2Enumerator) ──
    implementation("androidx.camera:camera-core:1.3.1")

    // ── JSON parsing for telemetry ──
    implementation("org.json:json:20231013")

    // ── Testing ──
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
