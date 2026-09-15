import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final ValueChanged<String> onBarcode;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcode,
  });

  @override
  State<BarcodeScannerWidget> createState() =>
      _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState
    extends State<BarcodeScannerWidget> {
  final MobileScannerController controller =
      MobileScannerController();

  bool handled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode / QR'),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (handled) return;

          for (final barcode in capture.barcodes) {
            final value = barcode.rawValue;

            if (value != null && value.isNotEmpty) {
              handled = true;
              widget.onBarcode(value);
              Navigator.of(context).pop(value);
              break;
            }
          }
        },
      ),
    );
  }
}
