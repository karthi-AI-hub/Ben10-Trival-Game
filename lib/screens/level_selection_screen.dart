import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'gameplay_screen.dart';
import '../widgets/grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For image filter if needed
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import 'gameplay_screen.dart';
import '../widgets/grid_painter.dart';
import '../widgets/game_dialogs.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final arena = game.arenas[game.selectedArenaIndex];
        final totalLevels = arena.aliens.length;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              arena.name.split(': ').last.toUpperCase(),
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            centerTitle: true,
            backgroundColor: AppColors.background.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)
                  ]
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          body: Stack(
            children: [
              // Animated Background Grid
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              
              SafeArea(
                child: Column(
                  children: [
                    // Holographic Progress Header
                    FadeTransition(
                      opacity: _controller,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 0),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('SECTOR PROGRESS', style: GoogleFonts.orbitron(fontSize: 14, color: Colors.grey)),
                                Text('${game.currentLevel} / $totalLevels', style: GoogleFonts.orbitron(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: totalLevels == 0 ? 0 : game.currentLevel / totalLevels,
                                backgroundColor: Colors.black45,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Interactive Level Grid
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: totalLevels,
                        itemBuilder: (context, index) {
                          final levelNum = index + 1;
                          final unlockedLevels = game.arenaProgress[game.selectedArenaIndex] ?? 1;
                          final isUnlocked = levelNum <= unlockedLevels;
                          final isCompleted = levelNum < unlockedLevels; // Or logic based on 'completed' if tracked separately
                          final isCurrent = levelNum == game.currentLevel;

                          // Stagger animation
                          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                (index / totalLevels).clamp(0.0, 0.8), 
                                1.0, 
                                curve: Curves.easeOutBack
                              ),
                            ),
                          );

                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Transform.scale(
                              scale: animation.value,
                              child: child,
                            ),
                            child: _HoloLevelTile(
                              levelNum: levelNum,
                              status: isCurrent ? LevelStatus.current 
                                     : isCompleted ? LevelStatus.completed
                                     : isUnlocked ? LevelStatus.unlocked 
                                     : LevelStatus.locked,
                              onTap: () async {
                                if (game.lives == 0) {
                                  GameDialogs.showLifeRefillDialog(context, game);
                                  return;
                                }
                                await game.setCurrentLevel(levelNum);
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GameplayScreen()),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum LevelStatus { locked, unlocked, completed, current }

class _HoloLevelTile extends StatefulWidget {
  final int levelNum;
  final LevelStatus status;
  final VoidCallback onTap;

  const _HoloLevelTile({
    required this.levelNum,
    required this.status,
    required this.onTap,
  });

  @override
  State<_HoloLevelTile> createState() => _HoloLevelTileState();
}

class _HoloLevelTileState extends State<_HoloLevelTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2)
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.status) {
      case LevelStatus.current: return AppColors.primary;
      case LevelStatus.completed: return AppColors.primary.withOpacity(0.5);
      case LevelStatus.unlocked: return AppColors.primary.withOpacity(0.3);
      case LevelStatus.locked: return Colors.white10;
    }
  }

  Color get _fillColor {
    switch (widget.status) {
      case LevelStatus.current: return AppColors.primary.withOpacity(0.2);
      case LevelStatus.completed: return AppColors.surface;
      case LevelStatus.unlocked: return AppColors.surface;
      case LevelStatus.locked: return Colors.black26;
    }
  }

  List<BoxShadow> get _shadows {
     if (widget.status == LevelStatus.current) {
       return [
         BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 10, spreadRadius: 1),
         BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
       ];
     }
     if (widget.status == LevelStatus.completed || widget.status == LevelStatus.unlocked) {
       return [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 5)];
     }
     return [];
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == LevelStatus.locked;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isLocked ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = widget.status == LevelStatus.current ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: _isPressed ? 1.0 : scale, // Don't pulse while pressing
              child: Container(
                decoration: BoxDecoration(
                  color: _fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, width: widget.status == LevelStatus.current ? 2 : 1),
                  boxShadow: _shadows,
                ),
                child: Center(
                  child: isLocked 
                    ? Icon(Icons.lock_outline, color: Colors.white24, size: 16)
                    : Text(
                        '${widget.levelNum}',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: widget.status == LevelStatus.current ? FontWeight.bold : FontWeight.w500,
                          color: widget.status == LevelStatus.current ? Colors.white : AppColors.primary,
                        ),
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
