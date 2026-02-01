import 'dart:convert';

import 'package:flutter/services.dart';

class CallDebugService {
  CallDebugService._();

  static const MethodChannel _channel = MethodChannel('call_info/debug');

  static Future<List<CallDebugEntry>> fetchLogs() async {
    final raw = await _channel.invokeMethod<String>('getCallLogs') ?? '[]';
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) =>
            CallDebugEntry.fromMap(entry as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> clearLogs() async {
    await _channel.invokeMethod('clearCallLogs');
  }
}

class CallDebugEntry {
  const CallDebugEntry({
    required this.callState,
    required this.phoneNumber,
    required this.source,
    required this.timestamp,
  });

  final String callState;
  final String? phoneNumber;
  final String source;
  final DateTime timestamp;

  factory CallDebugEntry.fromMap(Map<String, dynamic> map) {
    final timestampMillis = (map['timestamp'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    return CallDebugEntry(
      callState: map['callState'] as String? ?? 'UNKNOWN',
      phoneNumber: map['phoneNumber'] as String?,
      source: map['source'] as String? ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMillis),
    );
  }
}
