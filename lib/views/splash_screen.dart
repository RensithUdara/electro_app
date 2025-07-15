import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../widgets/particle_animation.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _textAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.elasticInOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _textScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.bounceOut),
    ));

    // Start animations with staggered timing
    _startAnimations();

    // Navigate after delay
    _navigateToNextScreen();
  }

  void _startAnimations() async {
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _textAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 100));
    _rotateController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

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

      if (authController.isLoggedIn || autoLoginSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Particle background animation (subtle on white background)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: ParticleAnimation(
                  particleCount: 10,
                  particleColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                  maxRadius: 1.5,
                ),
              ),
            ),
            
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with enhanced animations (no shadows)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeAnimation,
                    _scaleAnimation,
                    _rotateAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * 0.05,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 170,
                              height: 170,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Clean fallback design
                                return Container(
                                  width: 170,
                                  height: 170,
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
                                    size: 90,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App Name with slide and enhanced typography (dark blue)
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: ScaleTransition(
                      scale: _textScaleAnimation,
                      child: Column(
                        children: [
                          Text(
                            'ElectroApp',
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                              letterSpacing: 2.0,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Animated underline
                          AnimatedBuilder(
                            animation: _textAnimationController,
                            builder: (context, child) {
                              return Container(
                                width: 180 * _textAnimationController.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF1E3A8A),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Enhanced tagline (dark blue)
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      'Electrical Device Monitoring',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: const Color(0xFF1E3A8A).withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Loading indicator with clean design
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.05 * _rotateAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E3A8A).withOpacity(0.05),
                            border: Border.all(
                              color: const Color(0xFF1E3A8A).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const SpinKitWave(
                            color: Color(0xFF1E3A8A),
                            size: 30.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Loading text (dark blue)
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Text(
                    'Initializing...',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1E3A8A).withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Progress dots animation (dark blue)
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.3;
                          final animationValue = (_rotateController.value + delay) % 1.0;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E3A8A).withOpacity(
                                0.3 + (0.5 * animationValue),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
