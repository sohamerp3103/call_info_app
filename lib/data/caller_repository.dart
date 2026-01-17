import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/caller_details.dart';
import 'caller_database.dart';

class CallerRepository {
  CallerRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CallerDetails?> fetchCallerDetails(String phoneNumber) async {
    final local = await _fetchFromLocal(phoneNumber);
    if (local != null) {
      return local;
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
      return null;
    }

    return CallerDetails.fromMap(results.first);
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
