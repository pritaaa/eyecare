package com.example.eye_care_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScreenReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SCREEN_ON -> ScreenUsageManager.onScreenOn(context)
            Intent.ACTION_SCREEN_OFF -> ScreenUsageManager.onScreenOff(context)
        }
    }
}
