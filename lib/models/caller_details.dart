class CallerDetails {
  const CallerDetails({
    required this.phoneNumber,
    required this.name,
    required this.company,
    required this.outstandingBalance,
    required this.notes,
  });

  final String phoneNumber;
  final String name;
  final String company;
  final double outstandingBalance;
  final String notes;

  factory CallerDetails.fromMap(Map<String, Object?> map) {
    return CallerDetails(
      phoneNumber: map['phone_number'] as String,
      name: map['name'] as String,
      company: map['company'] as String? ?? 'Unknown',
      outstandingBalance:
          (map['outstanding_balance'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? 'No notes available.',
    );
  }
}
