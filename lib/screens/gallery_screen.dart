import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/alien.dart';
import '../theme/app_colors.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return DefaultTabController(
          length: game.arenas.length,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('ALIEN DATABASE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: AppColors.primary,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.transparent,
                tabs: game.arenas.map((arena) => Tab(text: arena.name.split(': ').last.toUpperCase())).toList(),
              ),
            ),
            body: TabBarView(
              children: game.arenas.asMap().entries.map((entry) {
                int arenaIndex = entry.key;
                final arena = entry.value;
                int currentArenaProgress = game.isArenaUnlocked(arenaIndex) ? 1000 : 0; // Simplified for display
                // Actually, let's use the actual progress from provider
                // We need to know how many are unlocked in this arena
                
                return _ArenaGallery(
                  aliens: arena.aliens,
                  arenaIndex: arenaIndex,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ArenaGallery extends StatelessWidget {
  final List<Alien> aliens;
  final int arenaIndex;

  const _ArenaGallery({required this.aliens, required this.arenaIndex});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: aliens.length,
            itemBuilder: (context, index) {
              final alien = aliens[index];
              // An alien is discovered if the player has reached that level in THIS arena
              // Or if the arena is already completed (unlocked next)
              bool isDiscovered = false;
              
              // This is a bit simplified, but let's say if we are in arena 2, all arena 1 are discovered
              if (game.selectedArenaIndex > arenaIndex) {
                 isDiscovered = true;
              } else if (game.selectedArenaIndex == arenaIndex) {
                 isDiscovered = index < game.currentLevel - 1;
              }

              return _AlienTile(
                alien: alien,
                isDiscovered: isDiscovered,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlienTile extends StatelessWidget {
  final Alien alien;
  final bool isDiscovered;

  const _AlienTile({
    required this.alien,
    required this.isDiscovered,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDiscovered ? () => _showAlienDetails(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDiscovered ? AppColors.primary.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorFiltered(
                  colorFilter: isDiscovered
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix([
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                  child: Image.asset(
                    alien.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
              child: Text(
                isDiscovered ? alien.answer : '???',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isDiscovered ? FontWeight.bold : FontWeight.normal,
                  color: isDiscovered ? Colors.white : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlienDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Image.asset(alien.imagePath),
            ),
            const SizedBox(height: 20),
            Text(
              alien.answer.toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text('OMNITRIX FILE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(
                    alien.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('DISMISS'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
