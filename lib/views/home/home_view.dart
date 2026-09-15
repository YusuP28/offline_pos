import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../viewmodels/pos_viewmodel.dart';
import '../fnb/fnb_view.dart';
import '../pos/retail_pos_view.dart';
import '../shifts/shift_view.dart';

class HomeView
    extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() =>
      _HomeViewState();
}

class _HomeViewState
    extends State<HomeView> {
  int _index = 0;

  static const screens = [
    RetailPosView(),
    FnbView(),
    ShiftView(),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm =
        context.watch<PosViewModel>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            _index,
        onDestinationSelected:
            (index) {
          if (index == 0) {
            vm.setMode(
              AppConstants.retailMode,
            );
          }

          if (index == 1) {
            vm.setMode(
              AppConstants.fnbMode,
            );
          }

          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.point_of_sale_outlined,
            ),
            selectedIcon: Icon(
              Icons.point_of_sale,
            ),
            label: 'Retail',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.restaurant_outlined,
            ),
            selectedIcon: Icon(
              Icons.restaurant,
            ),
            label: 'F&B',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Kas',
          ),
        ],
      ),
    );
  }
}
