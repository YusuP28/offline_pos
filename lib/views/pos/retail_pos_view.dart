import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/currency.dart';
import '../../viewmodels/pos_viewmodel.dart';
import '../../widgets/barcode_scanner_widget.dart';

class RetailPosView
    extends StatefulWidget {
  const RetailPosView({
    super.key,
  });

  @override
  State<RetailPosView>
      createState() =>
          _RetailPosViewState();
}

class _RetailPosViewState
    extends State<RetailPosView> {
  final TextEditingController
      _search =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final vm =
          context.read<PosViewModel>();

      vm.setMode(
        AppConstants.retailMode,
      );

      vm.loadProducts();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final barcode =
        await Navigator.of(context)
            .push<String>(
      MaterialPageRoute(
        builder: (_) =>
            BarcodeScannerWidget(
          onBarcode: (value) {
            Navigator.of(context)
                .pop(value);
          },
        ),
      ),
    );

    if (!mounted ||
        barcode == null) {
      return;
    }

    final found =
        await context
            .read<PosViewModel>()
            .addByBarcode(barcode);

    if (!found && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Barcode $barcode tidak ditemukan.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm =
        context.watch<PosViewModel>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Retail POS'),
        actions: [
          IconButton(
            onPressed: _scan,
            icon: const Icon(
              Icons.qr_code_scanner,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged:
                  vm.searchProducts,
              decoration:
                  const InputDecoration(
                hintText:
                    'Cari nama / SKU / barcode...',
                prefixIcon:
                    Icon(Icons.search),
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: vm.loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : GridView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      140,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          220,
                      childAspectRatio:
                          1.15,
                      crossAxisSpacing:
                          10,
                      mainAxisSpacing:
                          10,
                    ),
                    itemCount:
                        vm.products.length,
                    itemBuilder:
                        (context, index) {
                      final product =
                          vm.products[index];

                      return Card(
                        child: InkWell(
                          onTap: () =>
                              vm.addProduct(
                            product,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              12,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                      Center(
                                    child:
                                        Icon(
                                      Icons
                                          .inventory_2,
                                      size: 42,
                                      color: Theme.of(
                                        context,
                                      )
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  Currency
                                      .format(
                                    product
                                        .price,
                                  ),
                                ),
                                Text(
                                  'Stok: '
                                  '${product.stock:g}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet:
          SafeArea(
        child: Material(
          elevation: 12,
          child: Padding(
            padding:
                const EdgeInsets.all(12),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                if (vm.cart.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child:
                        ListView.builder(
                      itemCount:
                          vm.cart.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            vm.cart[index];

                        return ListTile(
                          dense: true,
                          title: Text(
                            item.product
                                .name,
                          ),
                          subtitle:
                              Text(
                            '${item.quantity:g} x '
                            '${Currency.format(item.product.price)}',
                          ),
                          leading:
                              IconButton(
                            onPressed: () =>
                                vm.decreaseProduct(
                              item.product,
                            ),
                            icon: const Icon(
                              Icons
                                  .remove_circle_outline,
                            ),
                          ),
                          trailing:
                              Text(
                            Currency
                                .format(
                              item.subtotal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL\n'
                        '${Currency.format(vm.total)}',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed:
                          vm.cart.isEmpty
                              ? null
                              : () => _pay(
                                    context,
                                    vm,
                                  ),
                      icon: const Icon(
                        Icons.payment,
                      ),
                      label:
                          const Text(
                        'Bayar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay(
    BuildContext context,
    PosViewModel vm,
  ) async {
    final controller =
        TextEditingController(
      text: vm.total.toString(),
    );

    final paid =
        await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Pembayaran Tunai',
          ),
          content: TextField(
            controller:
                controller,
            keyboardType:
                TextInputType.number,
            autofocus: true,
            decoration:
                const InputDecoration(
              labelText:
                  'Dibayar',
              prefixText:
                  'Rp ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child:
                  const Text(
                'Batal',
              ),
            ),
            FilledButton(
              onPressed: () {
                final amount =
                    int.tryParse(
                  controller.text
                      .replaceAll(
                    RegExp(
                      r'[^0-9]',
                    ),
                    '',
                  ),
                );

                Navigator.pop(
                  dialogContext,
                  amount,
                );
              },
              child:
                  const Text(
                'Bayar',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (paid == null) {
      return;
    }

    if (paid < vm.total) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Pembayaran kurang.',
            ),
          ),
        );
      }

      return;
    }

    final invoice =
        'INV-${DateTime.now().millisecondsSinceEpoch}';

    await vm.saveOrder(
      invoiceNumber: invoice,
      paid: paid,
      paymentMethod: 'cash',
      status:
          AppConstants.orderCompleted,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaksi tersimpan offline.',
        ),
      ),
    );
  }
}
