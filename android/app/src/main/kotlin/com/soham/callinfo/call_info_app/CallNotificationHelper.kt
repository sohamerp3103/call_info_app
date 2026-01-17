package com.soham.callinfo.call_info_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object CallNotificationHelper {
    private const val CHANNEL_ID = "caller_details"
    private const val CHANNEL_NAME = "Caller Details"
    private const val NOTIFICATION_ID = 1001

    fun showCallerDetailsNotification(
        context: Context,
        phoneNumber: String?,
        callState: String
    ) {
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            manager.createNotificationChannel(channel)
        }

        val intent = Intent(context, MainActivity::class.java).apply {
            action = "OPEN_CALLER_DETAILS"
            putExtra(CallIntentCache.EXTRA_PHONE_NUMBER, phoneNumber)
            putExtra(CallIntentCache.EXTRA_CALL_STATE, callState)
            putExtra(CallIntentCache.EXTRA_TIMESTAMP, System.currentTimeMillis())
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .setContentTitle("Open Caller Details")
            .setContentText("Tap to view customer info")
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        manager.notify(NOTIFICATION_ID, notification)
    }
}
