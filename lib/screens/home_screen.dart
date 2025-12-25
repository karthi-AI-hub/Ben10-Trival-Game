import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'arena_selection_screen.dart';
import 'gameplay_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../services/ad_mob_service.dart';
import '../widgets/grid_painter.dart';
import '../widgets/game_dialogs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldPop = await GameDialogs.showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<GameProvider>(
              builder: (context, game, child) => IconButton(
                icon: Icon(
                  game.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => game.toggleSound(),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/azmuth.webp', 
                height: 32, 
                width: 32,
                errorBuilder: (c, e, s) => const Icon(Icons.settings, color: AppColors.primary),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Grid Background
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
            
            Consumer<GameProvider>(
              builder: (context, game, child) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Logo
                        Image.asset(
                          'assets/logo.webp',
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 120),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ALIEN TRIVIA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(blurRadius: 10.0, color: AppColors.primary.withOpacity(0.5), offset: const Offset(0, 0)),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),

                        // Lives Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/classic/classic_watch.webp', 
                                height: 32, 
                                errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 28)
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${game.lives}/5',
                                style: GoogleFonts.orbitron(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (game.lives < 5) ...[
                                const SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () => GameDialogs.showLifeRefillDialog(context, game),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: AppColors.background, size: 20),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Play Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ArenaSelectionScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: AppColors.primary, width: 3),
                              image: const DecorationImage(
                                image: AssetImage('assets/Loader.webp'),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              ),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, spreadRadius: 2),
                              ],
                            ),
                            child: Text(
                              'PLAY',
                              style: GoogleFonts.orbitron(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Stats and Gallery Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ActionIndicator(
                                label: 'DATABASE',
                                imagePath: 'assets/Loader.webp',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryScreen())),
                              ),
                              // Azmuth for stats
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatsScreen())),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                        color: AppColors.surface,
                                      ),
                                      child: Image.asset('assets/azmuth.webp', height: 40, width: 40, errorBuilder: (c, e, s) => const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 30)),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'STATS',
                                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ), // Column
                  ), // SingleChildScrollView
                ); // Center
              }, // Builder
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIndicator extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onTap;

  const _ActionIndicator({
    required this.label, 
    this.icon, 
    this.imagePath, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              color: AppColors.surface,
            ),
            child: imagePath != null 
              ? Image.asset(imagePath!, height: 40, width: 40, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: AppColors.primary, size: 24))
              : Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}


