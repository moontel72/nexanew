package com.todd.broadcaster

import android.app.Application
import android.util.Log

/**
 * Application class for the Todd Broadcaster.
 * Handles one-time initialization (logging, crash handler).
 */
class BroadcasterApplication : Application() {

    companion object {
        private const val TAG = "ToddBroadcaster"
    }

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "Todd Broadcaster native v${BuildConfig.VERSION_NAME} starting")
        Log.i(TAG, "Device: ${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}")
        Log.i(TAG, "Android: ${android.os.Build.VERSION.RELEASE} (API ${android.os.Build.VERSION.SDK_INT})")
    }
}
