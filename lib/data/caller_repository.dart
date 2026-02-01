import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/caller_details.dart';
import 'caller_database.dart';

class CallerRepository {
  CallerRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final List<CallerDetails> _mockCallers = const [
    CallerDetails(
      phoneNumber: '+15551234567',
      name: 'Jordan Lee',
      company: 'Northwind Logistics',
      outstandingBalance: 2450.75,
      notes: 'Awaiting invoice approval from finance.',
    ),
    CallerDetails(
      phoneNumber: '+15559876543',
      name: 'Riley Chen',
      company: 'Contoso Health',
      outstandingBalance: 0.0,
      notes: 'Recently renewed contract. Follow up in Q3.',
    ),
    CallerDetails(
      phoneNumber: '+447700900123',
      name: 'Avery Patel',
      company: 'Fabrikam Retail',
      outstandingBalance: 810.0,
      notes: 'Requested urgent callback about shipment delay.',
    ),
  ];

  Future<CallerDetails?> fetchCallerDetails(String phoneNumber) async {
    final local = await _fetchFromLocal(phoneNumber);
    if (local != null) {
      return local;
    }

    final mock = _fetchFromMock(phoneNumber);
    if (mock != null) {
      return mock;
    }

    return _fetchFromApi(phoneNumber);
  }

  Future<CallerDetails?> _fetchFromLocal(String phoneNumber) async {
    final db = await CallerDatabase.instance.database;
    final results = await db.query(
      'callers',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );

    if (results.isEmpty) {
      return _fetchFromMock(phoneNumber);
    }

    return CallerDetails.fromMap(results.first);
  }

  CallerDetails? _fetchFromMock(String phoneNumber) {
    for (final caller in _mockCallers) {
      if (_isSameNumber(caller.phoneNumber, phoneNumber)) {
        return caller;
      }
    }
    return null;
  }

  bool _isSameNumber(String a, String b) {
    final normalizedA = _normalizeNumber(a);
    final normalizedB = _normalizeNumber(b);
    if (normalizedA.isEmpty || normalizedB.isEmpty) {
      return false;
    }
    if (normalizedA == normalizedB) {
      return true;
    }
    final minLength = 7;
    final suffixLength = normalizedA.length < normalizedB.length
        ? normalizedA.length
        : normalizedB.length;
    if (suffixLength < minLength) {
      return false;
    }
    return normalizedA.substring(normalizedA.length - suffixLength) ==
        normalizedB.substring(normalizedB.length - suffixLength);
  }

  String _normalizeNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\\D'), '');
    return digits;
  }

  Future<CallerDetails?> _fetchFromApi(String phoneNumber) async {
    // Placeholder for backend lookup. Replace with your API endpoint.
    final uri = Uri.parse('https://example.com/api/caller?phone=$phoneNumber');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload.isEmpty) {
      return null;
    }

    return CallerDetails(
      phoneNumber: phoneNumber,
      name: payload['name'] as String? ?? 'Unknown',
      company: payload['company'] as String? ?? 'Unknown',
      outstandingBalance:
          (payload['outstanding_balance'] as num?)?.toDouble() ?? 0,
      notes: payload['notes'] as String? ?? 'No notes available.',
    );
  }
}
