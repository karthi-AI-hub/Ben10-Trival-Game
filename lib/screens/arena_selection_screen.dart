import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'level_selection_screen.dart';
import '../widgets/grid_painter.dart';

class ArenaSelectionScreen extends StatelessWidget {
  const ArenaSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SELECT SERIES',
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          if (game.arenas.isEmpty) {
            return const Center(
              child: Text(
                'NO SERIES DATA FOUND',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7, // Adjusted for typical mobile screens
                      ),
                      itemCount: game.arenas.length,
                      itemBuilder: (context, index) {
                        final arena = game.arenas[index];
                        final isUnlocked = game.isArenaUnlocked(index);
                        
                        // Determine folder/logo based on index for robustness
                        // Index 0: Classic, 1: AF, 2: UA, 3: OV
                        String folder = 'classic';
                        if (index == 1) folder = 'af';
                        else if (index == 2) folder = 'ua';
                        else if (index == 3) folder = 'ov';

                        final logoPath = 'assets/$folder/${folder}_logo.webp';
                        final finalLogoPath = folder == 'ov' ? 'assets/ov/ov_logo.webp' : logoPath;

                        return GestureDetector(
                          onTap: isUnlocked ? () {
                            game.selectArena(index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
                            );
                          } : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isUnlocked ? AppColors.primary.withOpacity(0.5) : Colors.white10,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isUnlocked)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Column(
                                children: [
                                  const SizedBox(height: 15),
                                  // Series Logo
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Image.asset(
                                      finalLogoPath,
                                      height: 35,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        folder.toUpperCase(),
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white, 
                                          fontSize: 10, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Character Image
                                  Expanded(
                                    flex: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Opacity(
                                        opacity: isUnlocked ? 1.0 : 0.3,
                                        child: Image.asset(
                                          arena.arenaImage,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.person, color: Colors.grey, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Lock/Ready Overlay-style Footer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isUnlocked 
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.black26,
                                    ),
                                    child: Center(
                                      child: isUnlocked 
                                        ? Text(
                                            'PLAY',
                                            style: GoogleFonts.orbitron(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          )
                                        : const Icon(Icons.lock_rounded, color: Colors.grey, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


