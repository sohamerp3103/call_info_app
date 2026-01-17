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

    if (mounted) {
      setState(() {
        _phoneStatus = phone;
        _notificationStatus = notification;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.phone, Permission.notification].request();
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
            onRequest: _requestPermissions,
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
    required this.onRequest,
  });

  final PermissionStatus phoneStatus;
  final PermissionStatus notificationStatus;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final statusText = <String>[];
    statusText.add('Phone permission: ${phoneStatus.name}');
    statusText.add('Notification permission: ${notificationStatus.name}');

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
              'This app does not draw overlays or access call logs. '
              'If permissions are denied, you can still use manual lookup.',
            ),
            const SizedBox(height: 12),
            Text(statusText.join('\n')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRequest,
              child: const Text('Grant permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
