import '../core/database/db_helper.dart';
import '../models/shift.dart';

class ShiftRepository {
  final DbHelper db;

  ShiftRepository(this.db);

  Future<Shift?> getOpenShift() async {
    final rows = await db.query(
      'shifts',
      where: 'status = ?',
      whereArgs: ['open'],
      orderBy: 'opened_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Shift.fromMap(rows.first);
  }

  Future<int> openShift({
    required int openingCash,
    int? userId,
  }) async {
    final existing =
        await getOpenShift();

    if (existing != null) {
      throw StateError(
        'Shift masih terbuka.',
      );
    }

    return db.insert(
      'shifts',
      {
        'user_id': userId,
        'opening_cash': openingCash,
        'expected_cash': openingCash,
        'closing_cash': null,
        'cash_difference': null,
        'opened_at':
            DateTime.now().toIso8601String(),
        'closed_at': null,
        'status': 'open',
        'notes': null,
      },
    );
  }

  Future<void> closeShift({
    required int shiftId,
    required int closingCash,
    String? notes,
  }) async {
    final rows = await db.query(
      'shifts',
      where: 'id = ?',
      whereArgs: [shiftId],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw StateError(
        'Shift tidak ditemukan.',
      );
    }

    final expected =
        (rows.first['expected_cash']
                as num)
            .toInt();

    final difference =
        closingCash - expected;

    await db.update(
      'shifts',
      {
        'closing_cash': closingCash,
        'cash_difference': difference,
        'closed_at':
            DateTime.now().toIso8601String(),
        'status': 'closed',
        'notes': notes,
      },
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<int> cashSales(
    int shiftId,
  ) async {
    final database =
        await db.database;

    final result =
        await database.rawQuery('''
          SELECT COALESCE(SUM(total), 0)
          AS cash_sales
          FROM orders
          WHERE shift_id = ?
          AND status = 2
          AND payment_method = 'cash'
        ''', [shiftId]);

    return (result.first['cash_sales']
                as num?)
            ?.toInt() ??
        0;
  }
}
