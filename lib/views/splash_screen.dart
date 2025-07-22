import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  late AnimationController _taglineController;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _taglineScaleAnimation;

  late AnimationController _overallSlideController;
  late Animation<Offset> _overallSlideAnimation;

  @override
  void initState() {
    super.initState();

    _overallSlideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _overallSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _overallSlideController,
      curve: Curves.easeInOut,
    ));

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _taglineScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutBack),
    );

    // Animation Chain
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _textController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _taglineController.forward().then((_) {
              _overallSlideController.forward();
              Future.delayed(const Duration(milliseconds: 500), () {
                _navigateToNextScreen();
              });
            });
          });
        });
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (mounted) {
      final authController =
          Provider.of<AuthController>(context, listen: false);

      // Check login state (including persistent sessions and saved credentials)
      await authController.checkLoginState();

      // Try auto-login if user has valid session
      bool autoLoginSuccess = false;
      if (!authController.isLoggedIn) {
        autoLoginSuccess = await authController.tryAutoLogin();
      }

      Widget destinationScreen;

      if (authController.isLoggedIn || autoLoginSuccess) {
        destinationScreen = const HomeScreen();
      } else {
        destinationScreen = const LoginScreen();
      }

      // Use a fade transition to navigate
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              destinationScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            );
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _overallSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SlideTransition(
            position: _overallSlideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(
                              color: const Color(0xFF1E3A8A),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.electrical_services,
                            size: 120,
                            color: Color(0xFF1E3A8A),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      "ElectroApp",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _taglineFadeAnimation,
                  child: ScaleTransition(
                    scale: _taglineScaleAnimation,
                    child: Text(
                      "Electrical Device Monitoring",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF3B82F6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
