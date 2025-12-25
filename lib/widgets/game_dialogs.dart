import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../services/ad_mob_service.dart';
import '../theme/app_colors.dart';

class GameDialogs {
  static Future<bool> showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'EXIT MISSION?', 
          textAlign: TextAlign.center, 
          style: GoogleFonts.orbitron(color: AppColors.primary, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/classic/classic_watch.webp', 
              height: 80, 
              errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 64)
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to exit Ben 10 Trivia? Your progress is saved in the Omnitrix.', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showLifeRefillDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'CHARGE OMNITRIX?', 
          textAlign: TextAlign.center, 
          style: GoogleFonts.orbitron(color: AppColors.primary, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/classic/classic_watch.webp', 
              color: Colors.red, 
              height: 80, 
              errorBuilder: (c, e, s) => const Icon(Icons.bolt_rounded, color: Colors.red, size: 64)
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Omnitrix is out of power! Charge it now to continue your mission.', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NOT NOW', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!AdMobService().isRewardedLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No ad available. Connect to internet to recharge.')),
                );
                return;
              }
              
              AdMobService().showRewardedAd(
                onUserEarnedReward: () {
                  game.restoreLives(5);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Omnitrix Fully Charged! (5 Lives)')),
                  );
                },
                onAdDismissed: () {},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('WATCH AD TO RECHARGE'),
          ),
        ],
      ),
    );
  }
}
