import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency.dart';
import '../../viewmodels/pos_viewmodel.dart';

class FnbScreen extends StatefulWidget {
  const FnbScreen({super.key});

  @override
  State<FnbScreen> createState() => _FnbScreenState();
}

class _FnbScreenState extends State<FnbScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('F&B POS'),
          ),
          body: Column(
            children: [
              _TableSelector(vm: vm),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: vm.products.length,
                  itemBuilder: (_, index) {
                    final product = vm.products[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.restaurant),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        Currency.format(product.price),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () =>
                            vm.addToCart(product),
                      ),
                    );
                  },
                ),
              ),
              _FnbCart(vm: vm),
            ],
          ),
        );
      },
    );
  }
}

class _TableSelector extends StatelessWidget {
  final PosViewModel vm;

  const _TableSelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: vm.repository.getTables(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final tables = snapshot.data!;

        return SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            itemCount: tables.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final table = tables[index];
              final id = table['id'] as int;
              final selected = vm.selectedTableId == id;

              return ChoiceChip(
                selected: selected,
                label: Text(
                  'Meja ${table['table_number']}',
                ),
                onSelected: (_) => vm.selectTable(id),
              );
            },
          ),
        );
      },
    );
  }
}

class _FnbCart extends StatelessWidget {
  final PosViewModel vm;

  const _FnbCart({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            maxLines: 2,
            onChanged: vm.setKitchenNote,
            decoration: const InputDecoration(
              labelText: 'Catatan dapur',
              hintText: 'Contoh: Tidak pedas, tanpa bawang',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                Currency.format(vm.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  vm.cart.isEmpty || vm.selectedTableId == null
                      ? null
                      : () async {
                          try {
                            await vm.checkout(
                              amountPaid: vm.total,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Order tersimpan.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                              ),
                            );
                          }
                        },
              child: const Text('HOLD / SIMPAN ORDER'),
            ),
          ),
        ],
      ),
    );
  }
}
