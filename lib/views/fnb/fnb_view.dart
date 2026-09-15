import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/db_helper.dart';
import '../../core/utils/currency.dart';
import '../../viewmodels/pos_viewmodel.dart';

class FnbView extends StatefulWidget {
  const FnbView({super.key});

  @override
  State<FnbView> createState() =>
      _FnbViewState();
}

class _FnbViewState
    extends State<FnbView> {
  List<Map<String, dynamic>>
      _tables = [];

  final TextEditingController
      _notes =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<PosViewModel>()
          .setMode(
            AppConstants.fnbMode,
          );
    });

    _loadTables();
  }

  Future<void> _loadTables() async {
    final rows =
        await DbHelper.instance
            .query(
      'restaurant_tables',
      orderBy: 'id ASC',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _tables = rows;
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm =
        context.watch<PosViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F&B / Restaurant',
        ),
        actions: [
          IconButton(
            onPressed: () {
              vm.clearCart();
              _notes.clear();
            },
            icon: const Icon(
              Icons.delete_sweep,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child:
                ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              itemCount:
                  _tables.length,
              itemBuilder:
                  (context, index) {
                final table =
                    _tables[index];

                final id =
                    table['id'] as int;

                final selected =
                    vm.tableId == id;

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 8,
                  ),
                  child: ChoiceChip(
                    selected:
                        selected,
                    label: Text(
                      table['name']
                          as String,
                    ),
                    onSelected:
                        (_) => vm
                            .selectTable(
                      id,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: vm.cart.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada item.\n'
                      'Tambahkan item melalui Retail.',
                      textAlign:
                          TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount:
                        vm.cart.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          vm.cart[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            item.product
                                .name,
                          ),
                          subtitle:
                              Text(
                            '${item.quantity:g} x '
                            '${Currency.format(item.product.price)}',
                          ),
                          trailing:
                              Text(
                            Currency
                                .format(
                              item.subtotal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  onChanged:
                      vm.setKitchenNotes,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Catatan dapur',
                    hintText:
                        'Tidak pedas, tanpa bawang, dll.',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Currency
                            .format(
                          vm.total,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed:
                          vm.cart.isEmpty
                              ? null
                              : () async {
                                  final invoice =
                                      'FNB-${DateTime.now().millisecondsSinceEpoch}';

                                  await vm
                                      .saveOrder(
                                    invoiceNumber:
                                        invoice,
                                    status:
                                        AppConstants.orderHeld,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger
                                      .of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text(
                                        'Order di-hold.',
                                      ),
                                    ),
                                  );

                                  await _loadTables();
                                },
                      icon: const Icon(
                        Icons.pause,
                      ),
                      label:
                          const Text(
                        'Hold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
