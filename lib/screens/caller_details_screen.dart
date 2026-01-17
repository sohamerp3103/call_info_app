import 'package:flutter/material.dart';

import '../data/caller_repository.dart';
import '../models/caller_details.dart';

class CallerDetailsScreen extends StatefulWidget {
  const CallerDetailsScreen({
    super.key,
    required this.phoneNumber,
    required this.repository,
  });

  final String phoneNumber;
  final CallerRepository repository;

  @override
  State<CallerDetailsScreen> createState() => _CallerDetailsScreenState();
}

class _CallerDetailsScreenState extends State<CallerDetailsScreen> {
  late Future<CallerDetails?> _callerFuture;

  @override
  void initState() {
    super.initState();
    _callerFuture = widget.repository.fetchCallerDetails(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caller Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<CallerDetails?>(
          future: _callerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No details found for ${widget.phoneNumber}.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Try manual lookup or sync with your backend to enrich the '
                    'caller details. If the phone number was unavailable due to '
                    'permissions, you can paste it from your call log.',
                  ),
                ],
              );
            }

            final details = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(details.company),
                const Divider(height: 32),
                _InfoRow(label: 'Phone', value: details.phoneNumber),
                _InfoRow(
                  label: 'Outstanding',
                  value: '\$${details.outstandingBalance.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(details.notes),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
