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

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
    }
}

dependencies {
    // ── WebRTC native (libwebrtc Android build) ──
    // Provides: PeerConnectionFactory, Camera2Capturer, HardwareVideoEncoderFactory,
    // SurfaceViewRenderer, AudioDeviceModule — direct access to MediaCodec + libwebrtc C++.
    implementation("io.github.webrtc-sdk:android:125.0.0")

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
