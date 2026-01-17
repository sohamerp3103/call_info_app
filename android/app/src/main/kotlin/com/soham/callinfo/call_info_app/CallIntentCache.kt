package com.soham.callinfo.call_info_app

import android.content.Context
import android.content.Intent

object CallIntentCache {
    const val EXTRA_PHONE_NUMBER = "phoneNumber"
    const val EXTRA_CALL_STATE = "callState"
    const val EXTRA_TIMESTAMP = "timestamp"

    private var pendingPayload: Map<String, Any?>? = null

    fun fromIntent(context: Context, intent: Intent): Map<String, Any?>? {
        val number = intent.getStringExtra(EXTRA_PHONE_NUMBER)
            ?: CallDetailsStore.getLastNumber(context)
        val callState = intent.getStringExtra(EXTRA_CALL_STATE)
        if (number.isNullOrEmpty()) {
            return null
        }

        return mapOf(
            EXTRA_PHONE_NUMBER to number,
            EXTRA_CALL_STATE to (callState ?: "UNKNOWN"),
            EXTRA_TIMESTAMP to System.currentTimeMillis()
        )
    }

    fun store(payload: Map<String, Any?>) {
        pendingPayload = payload
    }

    fun consume(): Map<String, Any?>? {
        val payload = pendingPayload
        pendingPayload = null
        return payload
    }
}
