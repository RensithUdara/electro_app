import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/device_controller.dart';
import 'controllers/device_data_controller.dart';
import 'controllers/realtime_data_controller.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final authController = AuthController();
          authController.initializeAuthListener();
          return authController;
        }),
        ChangeNotifierProvider(create: (_) => DeviceController()),
        ChangeNotifierProvider(create: (_) => DeviceDataController()),
        ChangeNotifierProvider(create: (_) => RealtimeDataController()),
      ],
      child: MaterialApp(
        title: 'ElectroApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'System',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
