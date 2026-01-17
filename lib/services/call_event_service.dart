import 'dart:async';

import 'package:flutter/services.dart';

import '../models/call_event.dart';

class CallEventService {
  static final CallEventService instance = CallEventService._();

  CallEventService._();

  static const EventChannel _eventChannel =
      EventChannel('call_info/events');
  static const MethodChannel _intentChannel =
      MethodChannel('call_info/intent');

  final StreamController<CallEvent> _eventsController =
      StreamController.broadcast();
  final StreamController<String> _deepLinkController =
      StreamController.broadcast();

  Stream<CallEvent> get events => _eventsController.stream;
  Stream<String> get deepLinks => _deepLinkController.stream;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _intentChannel.setMethodCallHandler((call) async {
      if (call.method == 'openCallerDetails') {
        final payload = call.arguments as Map<dynamic, dynamic>?;
        final number = payload?['phoneNumber'] as String?;
        if (number != null && number.isNotEmpty) {
          _deepLinkController.add(number);
        }
      }
    });

    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        _eventsController.add(CallEvent.fromMap(event));
      }
    });

    final initial = await _intentChannel
        .invokeMethod<Map<dynamic, dynamic>>('getInitialCallData');
    final initialNumber = initial?['phoneNumber'] as String?;
    if (initialNumber != null && initialNumber.isNotEmpty) {
      _deepLinkController.add(initialNumber);
    }

    _initialized = true;
  }
}
