import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('OMNITRIX DATA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final totalAttempts = game.totalCorrect + game.totalWrong;
          final accuracy = totalAttempts == 0 ? 0.0 : (game.totalCorrect / totalAttempts) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Mission Analysis'),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Accuracy', '${accuracy.toStringAsFixed(1)}%', AppColors.primary),
                          _buildStatItem('Correct', '${game.totalCorrect}', AppColors.success),
                          _buildStatItem('Wrong', '${game.totalWrong}', AppColors.error),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Battery Depletions', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text('${game.totalLivesLost}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Achievements List
                _buildSectionTitle('Battle Merits'),
                const SizedBox(height: 15),
                _buildAchievementTile(
                  'Omnitrix Recruit',
                  'Identify 10 Aliens correctly',
                  game.totalCorrect >= 10,
                  Icons.watch_rounded,
                  AppColors.primary,
                ),
                _buildAchievementTile(
                  'Hero Time',
                  'Reach 50 correct identifications',
                  game.totalCorrect >= 50,
                  Icons.bolt_rounded,
                  Colors.amber,
                ),
                _buildAchievementTile(
                  'Series Veteran',
                  'Complete the Classic Arena',
                  (game.arenas.isNotEmpty && game.selectedArenaIndex > 0), // Simple check for now
                  Icons.stars_rounded,
                  Colors.blueAccent,
                ),
                _buildAchievementTile(
                  'Perfect Sync',
                  'Maintain 90%+ Accuracy (min 20 levels)',
                  accuracy >= 90 && game.totalCorrect >= 20,
                  Icons.sync_rounded,
                  AppColors.success,
                ),
                _buildAchievementTile(
                  'Galactic Legend',
                  'Complete all 4 Arenas',
                  false, // Placeholder as we don't have a global "complete" flag yet
                  Icons.workspace_premium_rounded,
                  Colors.purpleAccent,
                ),
                
                const SizedBox(height: 40),
                
                // Footer
                const Center(
                  child: Text(
                    'Update the Omnitrix with more data!',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(String title, String desc, bool isUnlocked, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surface : AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked ? Border.all(color: color.withOpacity(0.3), width: 2) : Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : Colors.grey[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnlocked ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
          else
            Icon(Icons.lock_outline_rounded, color: Colors.grey[800], size: 24),
        ],
      ),
    );
  }
}
