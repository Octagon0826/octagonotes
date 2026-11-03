
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Menyiapkan format tanggal Bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  runApp(const OctagonotesApp());
}

class OctagonotesApp extends StatelessWidget {
  const OctagonotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCTAGONOTES',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315C9B),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1D2939),
          elevation: 0,
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF315C9B),
          foregroundColor: Colors.white,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
