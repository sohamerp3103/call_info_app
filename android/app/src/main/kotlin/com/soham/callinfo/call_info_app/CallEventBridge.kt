package com.soham.callinfo.call_info_app

import io.flutter.plugin.common.EventChannel

object CallEventBridge {
    private var eventSink: EventChannel.EventSink? = null
    private val pendingEvents: MutableList<Map<String, Any?>> = mutableListOf()

    fun registerEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
        if (sink != null && pendingEvents.isNotEmpty()) {
            pendingEvents.forEach { sink.success(it) }
            pendingEvents.clear()
        }
    }

    fun sendEvent(payload: Map<String, Any?>) {
        val sink = eventSink
        if (sink != null) {
            sink.success(payload)
        } else {
            pendingEvents.add(payload)
        }
    }
}
