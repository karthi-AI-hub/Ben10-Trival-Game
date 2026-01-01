import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:games_services/games_services.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'arena_selection_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../services/ad_mob_service.dart';
import '../widgets/grid_painter.dart';
import '../widgets/game_dialogs.dart';
import '../services/tutorial_service.dart';
import '../services/prefs_service.dart';
import '../services/notification_service.dart';
import '../services/game_services_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _livesKey = GlobalKey();
  final GlobalKey _playKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _coinsKey = GlobalKey();
  final GlobalKey _dailyKey = GlobalKey();
  final GlobalKey _leaderboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForTutorial();
    });
  }

  Future<void> _checkForTutorial() async {
    final bool shown = await PrefsService.isTutorialShown();
    if (!shown && mounted) {
      // Delay slightly ensures widgets are rendered
      Future.delayed(const Duration(milliseconds: 500), _showTutorial);
    }
  }

  void _showTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "Play",
        keyTarget: _playKey,
        shape: ShapeLightFocus.RRect,
        radius: 50,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              title: "Start Mission",
              desc: "Tap here to enter the Omnitrix Arena and test your knowledge!",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Lives",
        keyTarget: _livesKey,
        shape: ShapeLightFocus.RRect,
        radius: 30,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              title: "Lives Tracking",
              desc: "Don't let this hit zero! Watch ads to recharge your energy.",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Coins",
        keyTarget: _coinsKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              title: "Omni-Coins",
              desc: "Earn coins from battles and daily rewards. Use them to buy lives!",
            ),
          ),
        ],
      ),
       TargetFocus(
        identify: "Daily",
        keyTarget: _dailyKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: _buildTutorialContent(
              title: "Daily Rewards",
              desc: "Check here every day for free coins and tasks!",
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Database",
        keyTarget: _galleryKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _buildTutorialContent(
              title: "Alien Database",
              desc: "Review the aliens you've unlocked.",
            ),
          ),
        ],
      ),
    ];

    TutorialService.show(
      context: context,
      targets: targets,
      onFinish: () => PrefsService.saveTutorialShown(true),
      onSkip: () => PrefsService.saveTutorialShown(true),
    );
  }

  Widget _buildTutorialContent({required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 20.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              desc,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await GameDialogs.showExitConfirmation(context);
  }

  void _showLifeRefillDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primary, width: 2)),
        title: Text(
          'RECHARGE ENERGY?',
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.battery_alert_rounded, color: AppColors.primary, size: 64),
            const SizedBox(height: 20),
            Text(
              'Watch a transmission to restore 5 lives!',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.orbitron(color: Colors.grey)),
          ),
          FutureBuilder<bool>(
            future: AdMobService().isConnected(),
            builder: (context, snapshot) {
              final bool isOnline = snapshot.data ?? true;
              return ElevatedButton(
                onPressed: !isOnline ? null : () {
                  if (!AdMobService().isRewardedLoaded) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transmission loading... Stand by.')),
                    );
                    return;
                  }

                  AdMobService().showRewardedAd(
                    onUserEarnedReward: () {
                      game.restoreLives(5);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Energy Restored!')),
                      );
                    },
                    onAdDismissed: () {},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? AppColors.primary : Colors.grey,
                  foregroundColor: Colors.black,
                ),
                child: Text(isOnline ? 'WATCH AD' : 'OFFLINE', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
              );
            }
          ),
           const SizedBox(height: 10),
          ElevatedButton(
            onPressed: game.coins >= 200 ? () async {
              final success = await game.buyFullLives();
              if (success && context.mounted) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Purchased Full Energy!')),
                 );
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber, 
              foregroundColor: Colors.black,
            ),
            child: Text('BUY FULL LIVES (200 Coins)', style: GoogleFonts.orbitron(color: game.coins >= 200 ? Colors.black : Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showDailyTasksDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purpleAccent, width: 2)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, color: Colors.purpleAccent),
            const SizedBox(width: 10),
            Text('DAILY SUPPLY', style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Daily Login
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sunny, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Daily Login", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12))),
                      ElevatedButton(
                        onPressed: game.canClaimDailyReward ? () async {
                          await game.claimDailyReward();
                          setState(() {}); 
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(game.canClaimDailyReward ? "+50" : "DONE", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text("Watch Ads for Coins", style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // Ad Ladder Visualization
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      final stepInitial = (index + 1) * 100;
                      final isCompleted = game.adsWatchedToday > index;
                      final isNext = game.adsWatchedToday == index;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isCompleted ? AppColors.primary : (isNext ? Colors.purpleAccent : Colors.grey),
                              child: isCompleted 
                                ? const Icon(Icons.check, size: 14, color: Colors.black)
                                : Text('${index + 1}', style: TextStyle(fontSize: 10, color: isNext ? Colors.white : Colors.black45)),
                            ),
                             const SizedBox(height: 4),
                            Text('+$stepInitial', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                if (game.adsWatchedToday < 5)
                  FutureBuilder<bool>(
                    future: AdMobService().isConnected(),
                    builder: (context, snapshot) {
                      final isOnline = snapshot.data ?? true;
                      final nextReward = game.nextAdReward;
                      
                      return ElevatedButton.icon(
                        onPressed: !isOnline ? null : () {
                           if (!AdMobService().isRewardedLoaded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transmission loading...')),
                            );
                            return;
                          }
                          AdMobService().showRewardedAd(
                            onUserEarnedReward: () async {
                              final amount = await game.watchAdForCoins();
                              if (context.mounted) {
                                Navigator.pop(context); 
                                _showDailyTasksDialog(context, game); 
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Recieved $amount Coins!')),
                                );
                              }
                            },
                            onAdDismissed: () {},
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: Text(isOnline ? "WATCH AD (+$nextReward Coins)" : "OFFLINE", style: GoogleFonts.orbitron()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                        ),
                      );
                    }
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.green),
                    ),
                    child: Text("All transmissions recieved!", textAlign: TextAlign.center, style: GoogleFonts.orbitron(color: Colors.green)),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CLOSE', style: GoogleFonts.orbitron(color: Colors.grey))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 120,
          leading: Consumer<GameProvider>(
             builder: (context, game, child) => Container(
                key: _coinsKey,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${game.coins}', style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
             ),
          ),
          actions: [
             IconButton(
              key: _dailyKey,
              icon: const Icon(Icons.card_giftcard, color: Colors.purpleAccent),
              onPressed: () => _showDailyTasksDialog(context, context.read<GameProvider>()),
            ),
             IconButton(
              key: _leaderboardKey,
              icon: const Icon(Icons.leaderboard_rounded, color: AppColors.primary),
              onPressed: () async {
                // Check simple signin status
                 try {
                   await GamesServices.showLeaderboards(
                     androidLeaderboardID: 'CgkIuJ6b0N8CEAIQAQ',
                   );
                 } catch (e) {
                   debugPrint("Leaderboard error: $e");
                   GameServicesHelper.signIn(); // Try sign in if failed
                 }
              },
            ),
            Consumer<GameProvider>(
              builder: (context, game, child) => IconButton(
                icon: Icon(
                  game.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: Colors.grey,
                ),
                onPressed: () => game.toggleSound(),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/azmuth.webp', 
                height: 28, 
                width: 28,
                errorBuilder: (c, e, s) => const Icon(Icons.settings, color: Colors.white),
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
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/logo.webp',
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 120),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // Lives Indicator
                        GestureDetector(
                          key: _livesKey,
                          onTap:  () {
                            if (game.lives >= 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Omnitrix Battery Full! ⚡'), duration: Duration(seconds: 1)),
                              );
                            } else {
                              _showLifeRefillDialog(context, game);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: game.lives == 0 ? Colors.red : AppColors.primary.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(color: (game.lives == 0 ? Colors.red : AppColors.primary).withOpacity(0.2), blurRadius: 15)
                              ]
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/classic/classic_watch.webp', 
                                  height: 32, 
                                  errorBuilder: (c, e, s) => const Icon(Icons.favorite, color: Colors.green, size: 28)
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${game.lives}/5',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: game.lives == 0 ? Colors.red : Colors.white,
                                  ),
                                ),
                                if (game.lives < 5) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.add_circle, color: AppColors.primary, size: 20),
                                ]
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Play Button
                        GestureDetector(
                          key: _playKey,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ArenaSelectionScreen()),
                            );
                          },
                          child: Container(
                            width: 260,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: AppColors.primary, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'PLAY',
                                style: GoogleFonts.orbitron(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Stats and Gallery Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _MenuButton(
                                key: _galleryKey,
                                label: 'DATABASE',
                                icon: Icons.grid_on_rounded,
                                imagePath: 'assets/Loader.webp',
                                color: Colors.cyan,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryScreen())),
                              ),
                              _MenuButton(
                                key: _statsKey,
                                label: 'STATS',
                                icon: Icons.bar_chart_rounded,
                                imagePath: 'assets/azmuth.webp',
                                color: Colors.orange,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatsScreen())),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? imagePath;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    super.key,
    required this.label, 
    required this.icon, 
    this.imagePath,
    required this.color, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [
                 BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)
              ]
            ),
            child: imagePath != null 
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(imagePath!, fit: BoxFit.contain),
                )
              : Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: Colors.grey, 
              fontSize: 10, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
