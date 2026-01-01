import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_provider.dart';
// import '../services/notification_service.dart';
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
               
               // Community & Rewards Section
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 10, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Community & Rewards", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),
                ListTile(
                   leading: const Icon(Icons.monetization_on, color: Colors.amber),
                   title: Text('My Coins: ${game.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   subtitle: const Text('Use coins for hints and power-ups!', style: TextStyle(color: Colors.grey)),
                ),
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.blue),
                  title: const Text('Official Website', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Visit ben10trivia.vercel.app', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                  onTap: () => game.launchWebsite(),
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.green),
                  title: const Text('Share & Earn', style: TextStyle(color: Colors.white)),
                  subtitle: game.shareCount < 5 
                      ? Text('Earn 100 coins (${game.shareCount}/5 claimed)', style: const TextStyle(color: Colors.grey))
                      : const Text('Max rewards claimed (Thank you!)', style: const TextStyle(color: Colors.greenAccent)),
                  trailing: game.shareCount < 5 
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('+100', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () => game.shareApp(),
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
                  title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                onTap: () => _launchUrl(context, 'https://ben10trivia.vercel.app/privacy'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.blue),
                  title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                onTap: () => _launchUrl(context, 'https://ben10trivia.vercel.app/terms'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'About Ben 10 Trivia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is a fan-made app. All characters and images are property of their respective owners. No copyright infringement intended.',
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
