class Shift {
  final int id;
  final int openingCash;
  final int expectedCash;
  final int? closingCash;
  final int? cashDifference;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String status;
  final String? notes;

  const Shift({
    required this.id,
    required this.openingCash,
    required this.expectedCash,
    this.closingCash,
    this.cashDifference,
    required this.openedAt,
    this.closedAt,
    required this.status,
    this.notes,
  });

  factory Shift.fromMap(
    Map<String, dynamic> map,
  ) {
    return Shift(
      id: map['id'] as int,
      openingCash:
          (map['opening_cash'] as num).toInt(),
      expectedCash:
          (map['expected_cash'] as num).toInt(),
      closingCash:
          (map['closing_cash'] as num?)?.toInt(),
      cashDifference:
          (map['cash_difference'] as num?)?.toInt(),
      openedAt:
          DateTime.parse(map['opened_at'] as String),
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.parse(
              map['closed_at'] as String,
            ),
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }
}
