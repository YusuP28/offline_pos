import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterService {
  PrinterService._();

  static final PrinterService instance = PrinterService._();

  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() {
    return _printer.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    await _printer.connect(device);
  }

  Future<void> disconnect() async {
    await _printer.disconnect();
  }

  Future<bool> isConnected() async {
    return await _printer.isConnected ?? false;
  }

  Future<Uint8List> buildReceipt({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    double tax = 0,
    double discount = 0,
    required double total,
    String paymentMethod = 'CASH',
    String qrisPayload = 'QRIS',
    String footer = 'Terima kasih',
    bool paper80mm = false,
  }) async {
    final profile = await CapabilityProfile.load();

    final generator = Generator(
      paper80mm ? PaperSize.mm80 : PaperSize.mm58,
      profile,
    );

    final bytes = <int>[];

    bytes.addAll(
      generator.text(
        storeName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );

    bytes.addAll(
      generator.text(
        'OFFLINE POS',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      ),
    );

    bytes.addAll(generator.hr());

    for (final item in items) {
      final name = '${item['name']}';
      final qty = (item['qty'] as num).toDouble();
      final price = (item['price'] as num).toDouble();
      final lineTotal = qty * price;

      bytes.addAll(
        generator.row([
          PosColumn(
            text: name,
            width: 6,
          ),
          PosColumn(
            text: '${qty.toStringAsFixed(0)} x',
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: lineTotal.toStringAsFixed(0),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(generator.hr());

    bytes.addAll(
      generator.row([
        PosColumn(text: 'Subtotal', width: 7),
        PosColumn(
          text: subtotal.toStringAsFixed(0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(text: 'Diskon', width: 7),
        PosColumn(
          text: discount.toStringAsFixed(0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(text: 'Pajak', width: 7),
        PosColumn(
          text: tax.toStringAsFixed(0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 7,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: total.toStringAsFixed(0),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
          ),
        ),
      ]),
    );

    bytes.addAll(
      generator.text(
        'Pembayaran: $paymentMethod',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );

    bytes.addAll(generator.feed(1));

    bytes.addAll(
      generator.text(
        '[ QRIS ]',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
    );

    bytes.addAll(
      generator.text(
        qrisPayload,
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      ),
    );

    bytes.addAll(generator.feed(1));

    bytes.addAll(
      generator.text(
        footer,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
    );

    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut());

    return Uint8List.fromList(bytes);
  }

  Future<void> printReceipt({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    double tax = 0,
    double discount = 0,
    required double total,
    String paymentMethod = 'CASH',
    bool paper80mm = false,
  }) async {
    final data = await buildReceipt(
      storeName: storeName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      paper80mm: paper80mm,
    );

    await _printer.writeBytes(data);
  }
}
