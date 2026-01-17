package com.soham.callinfo.call_info_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var intentChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "call_info/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    CallEventBridge.registerEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    CallEventBridge.registerEventSink(null)
                }
            })

        intentChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "call_info/intent"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method == "getInitialCallData") {
                    result.success(CallIntentCache.consume())
                } else {
                    result.notImplemented()
                }
            }
        }

        CallIntentCache.consume()?.let { payload ->
            intentChannel?.invokeMethod("openCallerDetails", payload)
        }
    }

    override fun getInitialRoute(): String {
        val number = intent.getStringExtra(CallIntentCache.EXTRA_PHONE_NUMBER)
        return if (!number.isNullOrEmpty()) {
            "/caller?number=${Uri.encode(number)}"
        } else {
            "/"
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val payload = CallIntentCache.fromIntent(intent)
        if (payload != null) {
            if (intentChannel != null) {
                intentChannel?.invokeMethod("openCallerDetails", payload)
            } else {
                CallIntentCache.store(payload)
            }
        }
    }
}
