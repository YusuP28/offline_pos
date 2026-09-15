import 'package:flutter/foundation.dart';

import '../repositories/pos_repository.dart';

class ShiftViewModel extends ChangeNotifier {
  final PosRepository repository;

  ShiftViewModel({PosRepository? repository})
      : repository = repository ?? PosRepository();

  Map<String, dynamic>? currentShift;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    currentShift = await repository.getOpenShift();

    loading = false;
    notifyListeners();
  }

  Future<void> openShift(double openingCash) async {
    await repository.openShift(
      openingCash: openingCash,
    );

    await load();
  }

  Future<void> closeShift(
    double actualCash, {
    String? note,
  }) async {
    final shift = currentShift;

    if (shift == null) {
      throw Exception('Tidak ada shift aktif.');
    }

    await repository.closeShift(
      shiftId: shift['id'] as int,
      actualCash: actualCash,
      note: note,
    );

    await load();
  }

  double get openingCash =>
      (currentShift?['opening_cash'] as num?)?.toDouble() ?? 0;

  double get cashSales =>
      (currentShift?['cash_sales'] as num?)?.toDouble() ?? 0;

  double get expectedCash => openingCash + cashSales;
}
