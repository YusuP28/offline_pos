import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency.dart';
import '../../viewmodels/shift_viewmodel.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftViewModel>(
      builder: (context, vm, _) {
        final shift = vm.currentShift;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kas Harian'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: shift == null
                ? _OpeningShift(vm: vm)
                : _ActiveShift(vm: vm),
          ),
        );
      },
    );
  }
}

class _OpeningShift extends StatelessWidget {
  final ShiftViewModel vm;

  const _OpeningShift({required this.vm});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buka Shift',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Kas Awal',
            prefixText: 'Rp ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final cash =
                  double.tryParse(controller.text) ?? 0;

              await vm.openShift(cash);

              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Shift berhasil dibuka.',
                    ),
                  ),
                );
              }
            },
            child: const Text('BUKA SHIFT'),
          ),
        ),
      ],
    );
  }
}

class _ActiveShift extends StatelessWidget {
  final ShiftViewModel vm;

  const _ActiveShift({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shift Aktif',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _Row(
          label: 'Kas Awal',
          value: Currency.format(vm.openingCash),
        ),
        _Row(
          label: 'Penjualan Cash',
          value: Currency.format(vm.cashSales),
        ),
        _Row(
          label: 'Kas Yang Diharapkan',
          value: Currency.format(vm.expectedCash),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.lock),
            label: const Text('TUTUP KAS'),
            onPressed: () => _close(context),
          ),
        ),
      ],
    );
  }

  Future<void> _close(BuildContext context) async {
    final controller = TextEditingController();

    final actual = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kas Akhir'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Uang fisik di laci',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                double.tryParse(controller.text) ?? 0,
              );
            },
            child: const Text('Tutup Kas'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (actual == null) return;

    await vm.closeShift(actual);

    if (!context.mounted) return;

    final difference = actual - vm.expectedCash;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shift ditutup. Selisih: ${Currency.format(difference)}',
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
