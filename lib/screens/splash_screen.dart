import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/game_provider.dart';
import '../services/ad_mob_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration.zero);
    
    // AdMobService().loadRewardedAd(); // Handled in init()
    await context.read<GameProvider>().initGame();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Logo
            Image.asset(
              'assets/logo.webp',
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 120),
            ),
            const SizedBox(height: 20),
            Text(
              'ALIEN TRIVIA',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 4,
                shadows: [
                  Shadow(blurRadius: 10.0, color: AppColors.primary, offset: Offset(0, 0)),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Custom Rotating Loader
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                'assets/Loader.webp',
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const SpinKitDoubleBounce(color: AppColors.primary, size: 80),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'SYNCHRONIZING OMNITRIX...',
              style: GoogleFonts.orbitron(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
