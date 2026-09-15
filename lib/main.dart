import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/db_helper.dart';
import 'viewmodels/pos_viewmodel.dart';
import 'viewmodels/shift_viewmodel.dart';
import 'views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DbHelper.instance.database;

  runApp(const OfflinePosApp());
}

class OfflinePosApp extends StatelessWidget {
  const OfflinePosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PosViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShiftViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline POS',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
