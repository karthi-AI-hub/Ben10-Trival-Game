import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/ad_mob_service.dart';
import '../theme/app_colors.dart';
import '../widgets/game_dialogs.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _heartController;
  
  String? _selectedAnswer;
  bool _isCorrect = false;
  bool _isLocked = false;
  List<String> _choices = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _heartController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChoices();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _loadChoices() {
    setState(() {
      _choices = context.read<GameProvider>().getLevelChoices();
      _selectedAnswer = null;
      _isLocked = false;
      _isCorrect = false;
    });
    _precacheNextImage();
  }

  void _precacheNextImage() {
    final game = context.read<GameProvider>();
    final currentArena = game.arenas[game.selectedArenaIndex];
    if (game.currentLevel < currentArena.aliens.length) {
      final nextAlien = currentArena.aliens[game.currentLevel];
      precacheImage(AssetImage(nextAlien.imagePath), context);
    }
  }

  void _handleAnswer(String choice) async {
    if (_isLocked) return;

    final game = context.read<GameProvider>();
    final isCorrect = choice == game.currentAlien?.answer;

    setState(() {
      _selectedAnswer = choice;
      _isCorrect = isCorrect;
      _isLocked = true;
    });

    if (isCorrect) {
      game.logCorrect();
      AudioService.playCorrect();
      _confettiController.play();
      
      final currentArena = game.arenas[game.selectedArenaIndex];
      // Check if it's the last level of the arena
      if (game.currentLevel == currentArena.aliens.length) {
        await game.incrementLevel();
        await Future.delayed(const Duration(seconds: 1));
        _showArenaCompleteModal();
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        
        if (game.currentLevel % 5 == 0) {
          _showLevelGateModal();
        } else {
          game.incrementLevel();
          _loadChoices();
        }
      }
    } else {
      game.logWrong();
      AudioService.playWrong();
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      _shakeController.forward(from: 0);
      _heartController.forward(from: 0).then((_) => _heartController.reverse());
      
      game.decrementLives();
      
      if (game.lives == 0) {
        _showGameOverModal();
      } else {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _selectedAnswer = null;
          _isLocked = false;
        });
      }
    }
  }

  void _showArenaCompleteModal() {
    final game = context.read<GameProvider>();
    final isLastArena = game.selectedArenaIndex == game.arenas.length - 1;
    
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primary),
        ),
        title: Text(
          isLastArena ? '🌍 ULTIMATE CHAMPION 🌍' : '🛡️ ARENA CONQUERED 🛡️',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(game.arenas[game.selectedArenaIndex].watchImage, height: 100, errorBuilder: (c, e, s) => const Icon(Icons.stars, color: AppColors.primary, size: 80)),
            const SizedBox(height: 20),
            Text(
              isLastArena 
                ? 'You have completed all arenas and mastered the Omnitrix!' 
                : 'You have cleared this series! The next arena is now unlocked.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('BACK TO OMNITRIX'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelGateModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Battery Depleted!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/azmuth.webp', height: 80, errorBuilder: (c, e, s) => const Icon(Icons.battery_alert_rounded, color: AppColors.primary, size: 64)),
            const SizedBox(height: 20),
            Text(
              'Your Omnitrix needs a quick recharge to continue to Level ${context.read<GameProvider>().currentLevel + 1}!',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          StatefulBuilder(
            builder: (context, setModalState) {
              bool isActuallyLoading = false;

              return ElevatedButton(
                onPressed: isActuallyLoading 
                  ? null 
                  : () async {
                    if (!AdMobService().isRewardedLoaded) {
                      setModalState(() => isActuallyLoading = true);
                      AdMobService().loadRewardedAd();
                      await Future.delayed(const Duration(seconds: 2));
                      if (!AdMobService().isRewardedLoaded && context.mounted) {
                        setModalState(() => isActuallyLoading = false);
                        // Fallback: If ad fails to load (offline/no fill), let user proceed
                        context.read<GameProvider>().incrementLevel();
                        _loadChoices();
                        Navigator.pop(context);
                        return;
                      }
                      setModalState(() => isActuallyLoading = false);
                    }
                    
                    if (context.mounted) {
                      AdMobService().showRewardedAd(
                        onUserEarnedReward: () {
                          context.read<GameProvider>().incrementLevel();
                          _loadChoices();
                          Navigator.pop(context);
                        },
                        onAdDismissed: () {},
                      );
                    }
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isActuallyLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                  : const Text('WATCH AD TO CONTINUE'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGameOverModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Timed Out!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.redAccent, BlendMode.modulate),
              child: Image.asset(context.read<GameProvider>().arenas[context.read<GameProvider>().selectedArenaIndex].watchImage, height: 80, errorBuilder: (c, e, s) => const Icon(Icons.timer_off_rounded, color: AppColors.error, size: 64)),
            ),
            const SizedBox(height: 20),
            const Text('Your Omnitrix has timed out! Watch a video to reboot with 5 lives.', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!AdMobService().isRewardedLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rebooting... Please wait.')));
                return;
              }
              AdMobService().showRewardedAd(
                onUserEarnedReward: () {
                  context.read<GameProvider>().restoreLives(5);
                  Navigator.pop(context);
                  setState(() {
                    _selectedAnswer = null;
                    _isLocked = false;
                  });
                },
                onAdDismissed: () {},
              );
            },
            child: const Text('WATCH AD TO REBOOT', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ABORT MISSION', style: TextStyle(color: Colors.grey)),
          ),
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
        final shouldExit = await GameDialogs.showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Consumer<GameProvider>(
            builder: (context, game, child) => Text(
              'LEVEL ${game.currentLevel}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<GameProvider>(
                builder: (context, game, child) => Row(
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.3).animate(
                        CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
                      ),
                      child: Image.asset(
                        game.arenas[game.selectedArenaIndex].watchImage, 
                        height: 24, 
                        errorBuilder: (c, e, s) => const Icon(Icons.watch_rounded, color: AppColors.primary, size: 20)
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${game.lives}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Consumer<GameProvider>(
              builder: (context, game, child) {
                if (game.currentAlien == null) {
                  return const Center(child: Text('Arena Mastered!', style: TextStyle(color: AppColors.primary, fontSize: 24)));
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    key: ValueKey('${game.selectedArenaIndex}_${game.currentLevel}'),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Alien Image
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            double offset = 0;
                            if (_shakeController.isAnimating) {
                              offset = 10 * (1 - _shakeController.value) * math.sin(6 * _shakeController.value * math.pi);
                            }
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: Container(
                                height: 280,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    game.currentAlien!.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline, size: 80, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        
                        // Question
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: Text(
                            game.currentAlien!.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.4),
                          ),
                        ),
                        
                        const Spacer(),

                        // Hint Section
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Consumer<GameProvider>(
                            builder: (context, game, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_choices.length > 2) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          if (game.coins < 50) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Not enough coins! Need 50. 🪙'), duration: Duration(seconds: 1)),
                                            );
                                            return;
                                          }
                                          
                                          final newChoices = await game.buyHint5050(_choices);
                                          if (newChoices != null) {
                                            setState(() {
                                              _choices = newChoices;
                                            });
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Omnitrix Data Decrypted! 50/50 Applied. 🔓')),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.lightbulb_rounded, color: Colors.yellow),
                                        label: Text('HINT (50)', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ] else ... [
                                     const Text("Data Decrypted", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                                  ]
                                ],
                              );
                            }
                          ),
                        ),
                        
                        // Choices Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _choices.length,
                          itemBuilder: (context, index) {
                            final choice = _choices[index];
                            final isSelected = _selectedAnswer == choice;
                            
                            Color btnColor = AppColors.surface;
                            Color textColor = Colors.white;
                            Color borderColor = AppColors.primary.withOpacity(0.3);

                            if (isSelected) {
                              btnColor = _isCorrect ? AppColors.success : AppColors.error;
                              textColor = AppColors.background;
                              borderColor = btnColor;
                            } else if (_isLocked && choice == game.currentAlien?.answer) {
                              btnColor = AppColors.success.withOpacity(0.3);
                              borderColor = AppColors.success;
                            }

                            return GestureDetector(
                              onTap: () => _handleAnswer(choice),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: btnColor,
                                  border: Border.all(color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: btnColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                                  ] : [],
                                ),
                                child: Center(
                                  child: Text(
                                    choice,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [AppColors.primary, AppColors.accent, Colors.white],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
