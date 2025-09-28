import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // <<<--- 1. IMPORT ADMOB
import 'package:quick_task_flutter/screens/task_list_screen.dart';
import 'package:quick_task_flutter/statistic/statistics_screen.dart';

// void main() { // main.dart  // <<<--- ORIGINAL
//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// MODIFIED main function
void main() async { // <<<--- 2. MAKE main ASYNC
  // Ensure Flutter bindings are initialized (needed for plugins like AdMob and other async operations before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK (wait until initialization completes)
  final InitializationStatus initStatus = await MobileAds.instance.initialize();

  // Once initialization is complete, run the main app wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask Flutter',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FA), // A subtle background
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 4.0,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.teal[400],
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          )),
      themeMode: ThemeMode.system, // Automatically switch theme based on system settings
      routes: {
        '/statistics': (context) => const StatisticsScreen(),
      },
      home: const TaskListScreen(), // This will be your main screen
    );
  }
}
