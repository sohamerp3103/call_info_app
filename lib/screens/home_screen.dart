import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/call_event.dart';
import '../services/call_event_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenCallerDetails,
  });

  final void Function(String phoneNumber) onOpenCallerDetails;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _manualNumberController =
      TextEditingController();
  final List<CallEvent> _events = [];
  StreamSubscription<CallEvent>? _eventSubscription;

  PermissionStatus _phoneStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _callLogStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _refreshPermissionStatus();
    _eventSubscription = CallEventService.instance.events.listen((event) {
      setState(() {
        _events.insert(0, event);
        if (_events.length > 10) {
          _events.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _manualNumberController.dispose();
    super.dispose();
  }

  Future<void> _refreshPermissionStatus() async {
    final phone = await Permission.phone.status;
    final notification = await Permission.notification.status;
    final callLog = await Permission.callLog.status;

    if (mounted) {
      setState(() {
        _phoneStatus = phone;
        _notificationStatus = notification;
        _callLogStatus = callLog;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.notification,
      Permission.callLog,
    ].request();
    await _refreshPermissionStatus();
  }

  Future<void> _requestPhonePermission() async {
    await Permission.phone.request();
    await _refreshPermissionStatus();
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
    await _refreshPermissionStatus();
  }

  Future<void> _requestCallLogPermission() async {
    await Permission.callLog.request();
    await _refreshPermissionStatus();
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
    await _refreshPermissionStatus();
  }

  void _openManualLookup() {
    final value = _manualNumberController.text.trim();
    if (value.isEmpty) {
      return;
    }

    widget.onOpenCallerDetails(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caller Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PermissionCard(
            phoneStatus: _phoneStatus,
            notificationStatus: _notificationStatus,
            callLogStatus: _callLogStatus,
            onRequest: _requestPermissions,
            onRequestPhone: _requestPhonePermission,
            onRequestNotification: _requestNotificationPermission,
            onRequestCallLog: _requestCallLogPermission,
            onOpenSettings: _openAppSettings,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual lookup',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manualNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Paste or type phone number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _openManualLookup,
                    child: const Text('Open Caller Details'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recent call events',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            const Text(
              'No call events yet. Incoming/outgoing calls will appear here when '
              'permissions are granted and the device allows call state access.',
            )
          else
            ..._events.map((event) {
              return ListTile(
                leading: const Icon(Icons.call),
                title: Text(event.callState),
                subtitle: Text(
                  event.phoneNumber ?? 'Number unavailable',
                ),
                trailing: Text(
                  TimeOfDay.fromDateTime(event.timestamp).format(context),
                ),
                onTap: event.phoneNumber == null
                    ? null
                    : () => widget.onOpenCallerDetails(event.phoneNumber!),
              );
            }),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.phoneStatus,
    required this.notificationStatus,
    required this.callLogStatus,
    required this.onRequest,
    required this.onRequestPhone,
    required this.onRequestNotification,
    required this.onRequestCallLog,
    required this.onOpenSettings,
  });

  final PermissionStatus phoneStatus;
  final PermissionStatus notificationStatus;
  final PermissionStatus callLogStatus;
  final VoidCallback onRequest;
  final VoidCallback onRequestPhone;
  final VoidCallback onRequestNotification;
  final VoidCallback onRequestCallLog;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final statusText = <String>[];
    statusText.add('Phone permission: ${phoneStatus.name}');
    statusText.add('Notification permission: ${notificationStatus.name}');
    statusText.add('Call log permission: ${callLogStatus.name}');

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission rationale',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'To detect call state changes we request the Phone permission. '
              'If the system does not expose caller numbers, you can grant '
              'Call Log access to resolve the most recent caller after the call '
              'ends. The app does not draw overlays. Manual lookup is always '
              'available if permissions are denied.',
            ),
            const SizedBox(height: 12),
            Text(statusText.join('\n')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onRequest,
                  child: const Text('Grant all'),
                ),
                OutlinedButton(
                  onPressed: onRequestPhone,
                  child: const Text('Phone'),
                ),
                OutlinedButton(
                  onPressed: onRequestNotification,
                  child: const Text('Notifications'),
                ),
                OutlinedButton(
                  onPressed: onRequestCallLog,
                  child: const Text('Call log'),
                ),
                OutlinedButton(
                  onPressed: onOpenSettings,
                  child: const Text('Open settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
