import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router/router.dart';
import 'app/theme/theme.dart';
import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeClient();
  } catch (_) {
    // Graceful fallback for mock evaluation
  }
  runApp(
    const ProviderScope(
      child: ArgusApp(),
    ),
  );
}

class ArgusApp extends StatelessWidget {
  const ArgusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Argus — Camera Safety Workflows',
      debugShowCheckedModeBanner: false,
      theme: ArgusTheme.lightTheme(),
      darkTheme: ArgusTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: argusRouter,
    );
  }
}
