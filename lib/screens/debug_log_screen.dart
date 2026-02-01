import 'package:flutter/material.dart';

import '../services/call_debug_service.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  late Future<List<CallDebugEntry>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = CallDebugService.fetchLogs();
  }

  Future<void> _refresh() async {
    setState(() {
      _logsFuture = CallDebugService.fetchLogs();
    });
  }

  Future<void> _clearLogs() async {
    await CallDebugService.clearLogs();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Event Debug Log'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<CallDebugEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(
              child: Text('No call events captured yet.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final entry = logs[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.callState,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Number: ${entry.phoneNumber ?? 'Unavailable'}'),
                  Text('Source: ${entry.source}'),
                  Text(
                    'Timestamp: ${entry.timestamp}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
