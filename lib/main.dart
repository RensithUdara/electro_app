import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          // Check login state when app starts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authController.checkLoginState();
          });
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
          textTheme: GoogleFonts.robotoTextTheme(),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
