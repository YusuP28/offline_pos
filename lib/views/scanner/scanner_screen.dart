import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pos_viewmodel.dart';
import '../../widgets/barcode_scanner_widget.dart';
import '../../widgets/hid_scanner_listener.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HidScannerListener(
      onScan: (barcode) async {
        final vm = context.read<PosViewModel>();

        await vm.scanBarcode(barcode);

        if (context.mounted) {
          Navigator.pop(context, barcode);
        }
      },
      child: BarcodeScannerWidget(
        onBarcode: (barcode) async {
          await context
              .read<PosViewModel>()
              .scanBarcode(barcode);
        },
      ),
    );
  }
}
