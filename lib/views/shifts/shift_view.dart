import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency.dart';
import '../../viewmodels/shift_viewmodel.dart';

class ShiftView extends StatefulWidget {
  const ShiftView({super.key});

  @override
  State<ShiftView> createState() =>
      _ShiftViewState();
}

class _ShiftViewState
    extends State<ShiftView> {
  final TextEditingController
      _opening =
      TextEditingController(
    text: '0',
  );

  final TextEditingController
      _closing =
      TextEditingController(
    text: '0',
  );

  final TextEditingController
      _notes =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => context
          .read<ShiftViewModel>()
          .load(),
    );
  }

  @override
  void dispose() {
    _opening.dispose();
    _closing.dispose();
    _notes.dispose();
    super.dispose();
  }

  int _money(
    TextEditingController controller,
  ) {
    return int.tryParse(
          controller.text.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ),
        ) ??
        0;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm =
        context.watch<ShiftViewModel>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Kas Harian'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: vm.loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : vm.isOpen
                ? _open(context, vm)
                : _closed(context, vm),
      ),
    );
  }

  Widget _closed(
    BuildContext context,
    ShiftViewModel vm,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Buka Shift',
          style: Theme.of(context)
              .textTheme
              .headlineSmall,
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          controller: _opening,
          keyboardType:
              TextInputType.number,
          decoration:
              const InputDecoration(
            labelText:
                'Kas Awal',
            prefixText:
                'Rp ',
            border:
                OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        FilledButton.icon(
          onPressed: () async {
            try {
              await vm.open(
                openingCash:
                    _money(
                  _opening,
                ),
              );

              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Shift dibuka.',
                  ),
                ),
              );
            } catch (e) {
              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content:
                      Text('$e'),
                ),
              );
            }
          },
          icon: const Icon(
            Icons.login,
          ),
          label:
              const Text(
            'Buka Kas',
          ),
        ),
      ],
    );
  }

  Widget _open(
    BuildContext context,
    ShiftViewModel vm,
  ) {
    final shift = vm.shift!;

    return ListView(
      children: [
        Card(
          child: ListTile(
            title:
                const Text(
              'Shift Aktif',
            ),
            subtitle:
                Text(
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(
                shift.openedAt,
              ),
            ),
            trailing:
                const Chip(
              label:
                  Text('OPEN'),
            ),
          ),
        ),
        ListTile(
          title:
              const Text(
            'Kas Awal',
          ),
          trailing:
              Text(
            Currency.format(
              shift.openingCash,
            ),
          ),
        ),
        FutureBuilder<int>(
          future:
              vm.cashSales(),
          builder:
              (context, snapshot) {
            return ListTile(
              title:
                  const Text(
                'Penjualan Tunai',
              ),
              trailing:
                  Text(
                Currency.format(
                  snapshot.data ??
                      0,
                ),
              ),
            );
          },
        ),
        const Divider(),
        TextField(
          controller: _closing,
          keyboardType:
              TextInputType.number,
          decoration:
              const InputDecoration(
            labelText:
                'Kas Akhir Aktual',
            prefixText:
                'Rp ',
            border:
                OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration:
              const InputDecoration(
            labelText:
                'Catatan',
            border:
                OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        FilledButton.icon(
          style:
              FilledButton.styleFrom(
            backgroundColor:
                Colors.red,
          ),
          onPressed: () async {
            try {
              await vm.close(
                closingCash:
                    _money(
                  _closing,
                ),
                notes:
                    _notes.text.trim(),
              );

              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Shift ditutup.',
                  ),
                ),
              );
            } catch (e) {
              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content:
                      Text('$e'),
                ),
              );
            }
          },
          icon: const Icon(
            Icons.logout,
          ),
          label:
              const Text(
            'Tutup Kas',
          ),
        ),
      ],
    );
  }
}
