import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pos_viewmodel.dart';
import '../fnb/fnb_screen.dart';
import '../retail/retail_screen.dart';
import '../shift/shift_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline POS'),
        actions: [
          IconButton(
            tooltip: 'Kas Harian',
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShiftScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.point_of_sale,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'OFFLINE POS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.store),
                label: const Text(
                  'RETAIL MODE',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  context.read<PosViewModel>().setMode('retail');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RetailScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restaurant),
                label: const Text(
                  'F&B MODE',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  context.read<PosViewModel>().setMode('fnb');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FnbScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
