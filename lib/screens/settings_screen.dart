import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('OMNITRIX SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/azmuth.webp', height: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<GameProvider>(
          builder: (context, game, child) => Column(
            children: [
              SwitchListTile(
                secondary: Icon(
                  game.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, 
                  color: AppColors.primary
                ),
                title: const Text('Sonic Waves', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(game.soundEnabled ? 'ACTIVE' : 'MUTED', style: const TextStyle(color: Colors.grey)),
                activeColor: AppColors.primary,
                value: game.soundEnabled,
                onChanged: (value) => game.toggleSound(),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                title: const Text('Reset Omnitrix', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Clear all mission logs', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  _showResetDialog(context);
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded, color: Colors.blue),
                title: const Text('Plumber Privacy', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.grey),
                onTap: () => _launchUrl(context, 'https://ben10trivia.vercel.app/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.description_rounded, color: Colors.blue),
                title: const Text('Galactic Terms', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.grey),
                onTap: () => _launchUrl(context, 'https://ben10trivia.vercel.app/terms'),
              ),
              const Spacer(),
              const Text(
                'BEN 10: ALIEN TRIVIA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fan-made contribution to the Ben 10 Universe.\nAll assets are property of their respective owners.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Mission?', style: TextStyle(color: AppColors.primary)),
        content: const Text('This will wipe all Arena progress and collection data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('STAY', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Omnitrix reformatted!')),
              );
            },
            child: const Text('RESET', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
