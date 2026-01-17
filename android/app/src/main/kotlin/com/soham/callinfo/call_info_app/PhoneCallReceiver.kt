package com.soham.callinfo.call_info_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager

class PhoneCallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            return
        }

        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        val timestamp = System.currentTimeMillis()

        if (!incomingNumber.isNullOrEmpty()) {
            CallDetailsStore.saveLastNumber(context, incomingNumber)
        }

        val payload = mapOf(
            CallIntentCache.EXTRA_PHONE_NUMBER to incomingNumber,
            CallIntentCache.EXTRA_CALL_STATE to state,
            CallIntentCache.EXTRA_TIMESTAMP to timestamp
        )

        // Send call state updates to Flutter via EventChannel.
        CallEventBridge.sendEvent(payload)

        when (state) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                CallStateTracker.pendingNotificationWithoutNumber = incomingNumber.isNullOrEmpty()
                if (!incomingNumber.isNullOrEmpty()) {
                    CallNotificationHelper.showCallerDetailsNotification(
                        context,
                        incomingNumber,
                        state
                    )
                }
            }
            TelephonyManager.EXTRA_STATE_IDLE -> {
                if (CallStateTracker.pendingNotificationWithoutNumber) {
                    // If the number wasn't available during ringing, notify after the call ends
                    // and attach the last known number so the app can open details when possible.
                    val lastKnown = CallDetailsStore.getLastNumber(context)
                    CallNotificationHelper.showCallerDetailsNotification(
                        context,
                        lastKnown,
                        state
                    )
                }
                CallStateTracker.pendingNotificationWithoutNumber = false
            }
        }

        CallStateTracker.lastCallState = state
    }
}
