package com.soham.callinfo.call_info_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class PhoneCallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {

            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val incomingNumber =
                intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                Log.d("CALL_POC", "Incoming call: $incomingNumber")

                val serviceIntent =
                    Intent(context, CallerOverlayService::class.java)
                serviceIntent.putExtra("number", incomingNumber)

                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }

            }
        }
    }
}
