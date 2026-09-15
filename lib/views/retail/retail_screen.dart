import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency.dart';
import '../../viewmodels/pos_viewmodel.dart';
import '../scanner/scanner_screen.dart';

class RetailScreen extends StatefulWidget {
  const RetailScreen({super.key});

  @override
  State<RetailScreen> createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosViewModel>().loadProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Retail POS'),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScannerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  onChanged: vm.setSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari produk / barcode / SKU',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScannerScreen(),
                          ),
                        );
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: vm.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: vm.products.length,
                        itemBuilder: (_, index) {
                          final product = vm.products[index];

                          return Card(
                            child: InkWell(
                              onTap: () => vm.addToCart(product),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      Currency.format(product.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _CartPanel(vm: vm),
            ],
          ),
        );
      },
    );
  }
}

class _CartPanel extends StatelessWidget {
  final PosViewModel vm;

  const _CartPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Keranjang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text('${vm.cart.length} item'),
            ],
          ),
          const SizedBox(height: 8),
          if (vm.cart.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: vm.cart.length,
                itemBuilder: (_, index) {
                  final item = vm.cart[index];

                  return Row(
                    children: [
                      Expanded(
                        child: Text(item.product.name),
                      ),
                      IconButton(
                        onPressed: () =>
                            vm.decrease(item.product),
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        item.quantity.toStringAsFixed(0),
                      ),
                      IconButton(
                        onPressed: () =>
                            vm.increase(item.product),
                        icon: const Icon(Icons.add),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          Currency.format(item.subtotal),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              Text(
                Currency.format(vm.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.cart.isEmpty
                  ? null
                  : () => _checkout(context, vm),
              child: const Text('BAYAR'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(
    BuildContext context,
    PosViewModel vm,
  ) async {
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Pembayaran'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Uang diterima',
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
                final value =
                    double.tryParse(controller.text) ?? 0;
                Navigator.pop(context, value);
              },
              child: const Text('Proses'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) return;

    if (amount < vm.total) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang pembayaran kurang.'),
        ),
      );

      return;
    }

    try {
      await vm.checkout(amountPaid: amount);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan offline.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }
}
