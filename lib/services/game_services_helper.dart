import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

class GameServicesHelper {
  static const String _saveName = 'ben10_trivia_save';
  static const String _leaderboardId = 'CgkIuJ6b0N8CEAIQAQ';

  static Future<void> signIn() async {
    debugPrint('Game Services: Attempting Sign In...');
    try {
      await GameAuth.signIn();
      debugPrint('Game Services: Signed in successfully.');
    } catch (e) {
      debugPrint('Game Services: Sign in failed: $e');
    }
  }

  static Future<void> saveToCloud(int lives, int selectedArena, Map<int, int> arenaProgress, Map<String, int> stats) async {
    debugPrint('Game Services: Attempting Cloud Save...');
    try {
      final data = json.encode({
        'lives': lives,
        'selectedArena': selectedArena,
        'arenaProgress': arenaProgress.map((k, v) => MapEntry(k.toString(), v)),
        'stats': stats,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('Game Services: Data to save: $data');
      
      await GamesServices.saveGame(name: _saveName, data: data);
      debugPrint('Game Services: Saved to cloud successfully.');
    } catch (e) {
      debugPrint('Game Services: Save failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadFromCloud() async {
    debugPrint('Game Services: Attempting Cloud Load...');
    try {
      final jsonString = await GamesServices.loadGame(name: _saveName);
      if (jsonString != null) {
        debugPrint('Game Services: Loaded from cloud: $jsonString');
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        debugPrint('Game Services: No cloud save found.');
      }
    } catch (e) {
      debugPrint('Game Services: Load failed: $e');
    }
    return null;
  }

  static Future<void> submitScore({required int score, bool retry = true}) async {
    debugPrint('Game Services: Attempting to submit score: $score to $_leaderboardId');
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: _leaderboardId,
          value: score,
        ),
      );
      debugPrint('Game Services: Score submitted successfully.');
    } catch (e) {
      debugPrint('Game Services: Score submission failed: $e');
      if (retry) {
        debugPrint('Game Services: Attempting to reconnect and retry submission...');
        try {
           // Try signing out first to force specific account selection/refresh
           // try { await GamesServices.signOut(); } catch (e) { debugPrint('SignOut check: $e'); } // Removed as not supported
           
           final result = await GameAuth.signIn(); 
           debugPrint('Game Services: Re-sign in result: $result');
           
           if (result != null) {
              await Future.delayed(const Duration(seconds: 1)); // Wait for connection to stabilize
              await submitScore(score: score, retry: false);
           }
        } catch (retryError) {
           debugPrint('Game Services: Retry failed: $retryError');
        }
      }
    }
  }
}
