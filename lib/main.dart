import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'services/payment_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = PaymentController(prefs: prefs);
  await controller.loadSettings();
  runApp(YapeGananciasApp(controller: controller));
}

class YapeGananciasApp extends StatelessWidget {
  const YapeGananciasApp({super.key, required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ganancias por Yape',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7B2CBF),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F3FF),
            useMaterial3: true,
          ),
          home: HomeScreen(controller: controller),
        );
      },
    );
  }
}
