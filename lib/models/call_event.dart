class CallEvent {
  const CallEvent({
    required this.callState,
    required this.timestamp,
    this.phoneNumber,
  });

  final String callState;
  final String? phoneNumber;
  final DateTime timestamp;

  factory CallEvent.fromMap(Map<dynamic, dynamic> map) {
    return CallEvent(
      callState: map['callState'] as String? ?? 'UNKNOWN',
      phoneNumber: map['phoneNumber'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
