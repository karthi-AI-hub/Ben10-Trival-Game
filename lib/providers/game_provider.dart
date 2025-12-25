import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alien.dart';
import '../services/prefs_service.dart';

class Arena {
  final String name;
  final String jsonPath;
  final String arenaImage;
  final String watchImage;
  List<Alien> aliens;

  Arena({
    required this.name, 
    required this.jsonPath, 
    required this.arenaImage,
    required this.watchImage,
    this.aliens = const []
  });
}

class GameProvider with ChangeNotifier {
  final List<Arena> _arenas = [
    Arena(
      name: 'Ben 10: Classic', 
      jsonPath: 'assets/data/classic.json',
      arenaImage: 'assets/classic/classic_ben.webp',
      watchImage: 'assets/classic/classic_watch.webp',
    ),
    Arena(
      name: 'Ben 10: Alien Force', 
      jsonPath: 'assets/data/af.json',
      arenaImage: 'assets/af/af_ben.webp',
      watchImage: 'assets/af/af_watch.webp',
    ),
    Arena(
      name: 'Ben 10: Ultimate Alien', 
      jsonPath: 'assets/data/ua.json',
      arenaImage: 'assets/ua/ua_ben.webp',
      watchImage: 'assets/ua/ua_watch.webp',
    ),
    Arena(
      name: 'Ben 10: Omniverse', 
      jsonPath: 'assets/data/ov.json',
      arenaImage: 'assets/ov/ov_ben.webp',
      watchImage: 'assets/ov/ov_watch.webp',
    ),
  ];

  int _selectedArenaIndex = 0;
  int _currentLevel = 1;
  int _lives = 5;
  int _totalCorrect = 0;
  int _totalWrong = 0;
  int _totalLivesLost = 0;
  bool _isLoading = true;
  bool _soundEnabled = true;

  // Track highest level completed per arena
  Map<int, int> _arenaProgress = {0: 1, 1: 0, 2: 0, 3: 0}; 

  List<Arena> get arenas => _arenas;
  int get selectedArenaIndex => _selectedArenaIndex;
  int get currentLevel => _currentLevel;
  int get lives => _lives;
  int get totalCorrect => _totalCorrect;
  int get totalWrong => _totalWrong;
  int get totalLivesLost => _totalLivesLost;
  bool get isLoading => _isLoading;
  bool get soundEnabled => _soundEnabled;
  Map<int, int> get arenaProgress => _arenaProgress;

  Alien? get currentAlien {
    final arena = _arenas[_selectedArenaIndex];
    if (arena.aliens.isEmpty || _currentLevel > arena.aliens.length) return null;
    return arena.aliens[_currentLevel - 1];
  }

  Future<void> initGame() async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Load data for all arenas
      for (var arena in _arenas) {
        try {
          final String response = await rootBundle.loadString(arena.jsonPath);
          final data = await json.decode(response) as List;
          arena.aliens = data.map((e) => Alien.fromJson(e)).toList();
        } catch (e) {
          debugPrint('Error loading arena ${arena.name}: $e');
          // If a specific arena fails, we continue with others
          arena.aliens = []; 
        }
      }

      // Load progress
      _selectedArenaIndex = await _loadArenaIndex();
      _arenaProgress = await _loadArenaProgress();
      _currentLevel = _arenaProgress[_selectedArenaIndex] ?? 1;

      if (_currentLevel == 0) _currentLevel = 1;

      _lives = await PrefsService.getLives();
      _soundEnabled = await PrefsService.isSoundEnabled();

      // Load stats
      final stats = await PrefsService.getStats();
      _totalCorrect = stats['correct']!;
      _totalWrong = stats['wrong']!;
      _totalLivesLost = stats['livesLost']!;

    } catch (e) {
      debugPrint('Critical error in initGame: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> _loadArenaIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_arena') ?? 0;
  }

  Future<Map<int, int>> _loadArenaProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> progress = {};
    for (int i = 0; i < _arenas.length; i++) {
       progress[i] = prefs.getInt('arena_progress_$i') ?? (i == 0 ? 1 : 0);
    }
    return progress;
  }

  Future<void> selectArena(int index) async {
    if (isArenaUnlocked(index)) {
      _selectedArenaIndex = index;
      _currentLevel = _arenaProgress[index] == 0 ? 1 : _arenaProgress[index]!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_arena', index);
      notifyListeners();
    }
  }

  bool isArenaUnlocked(int index) {
    return (_arenaProgress[index] ?? 0) > 0;
  }

  List<String> getLevelChoices() {
    if (currentAlien == null) return [];

    String correctAnswer = currentAlien!.answer;
    List<String> distractors = [];
    Random random = Random();

    // Pool distractors from ALL aliens for better difficulty
    List<Alien> allAliensPool = _arenas.expand((a) => a.aliens).toList();

    while (distractors.length < 3) {
      int index = random.nextInt(allAliensPool.length);
      String randomName = allAliensPool[index].answer;
      if (randomName != correctAnswer && !distractors.contains(randomName)) {
        distractors.add(randomName);
      }
    }

    List<String> choices = [correctAnswer, ...distractors];
    choices.shuffle();
    return choices;
  }

  Future<void> incrementLevel() async {
    final arena = _arenas[_selectedArenaIndex];
    if (_currentLevel <= arena.aliens.length) {
      _currentLevel++;
      
      // Update progress for current arena
      if (_currentLevel > (_arenaProgress[_selectedArenaIndex] ?? 0)) {
        _arenaProgress[_selectedArenaIndex] = _currentLevel;
        await _saveArenaProgress(_selectedArenaIndex, _currentLevel);
      }

      // Check if arena is completed
      if (_currentLevel > arena.aliens.length) {
        // Unlock next arena if available
        if (_selectedArenaIndex < _arenas.length - 1) {
          if ((_arenaProgress[_selectedArenaIndex + 1] ?? 0) == 0) {
            _arenaProgress[_selectedArenaIndex + 1] = 1;
            await _saveArenaProgress(_selectedArenaIndex + 1, 1);
          }
        }
      }

      notifyListeners();
    }
  }

  Future<void> _saveArenaProgress(int index, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('arena_progress_$index', level);
  }

  Future<void> setCurrentLevel(int level) async {
    final arena = _arenas[_selectedArenaIndex];
    if (level >= 1 && level <= (arena.aliens.length)) {
      _currentLevel = level;
      // We don't necessarily update highest level here unless they play it
      notifyListeners();
    }
  }

  Future<void> decrementLives() async {
    if (_lives > 0) {
      _lives--;
      _totalLivesLost++;
      await PrefsService.saveLives(_lives);
      await _saveCurrentStats();
      notifyListeners();
    }
  }

  Future<void> logCorrect() async {
    _totalCorrect++;
    await _saveCurrentStats();
    notifyListeners();
  }

  Future<void> logWrong() async {
    _totalWrong++;
    await _saveCurrentStats();
    notifyListeners();
  }

  Future<void> _saveCurrentStats() async {
    await PrefsService.saveStats(
      correct: _totalCorrect,
      wrong: _totalWrong,
      livesLost: _totalLivesLost,
    );
  }

  Future<void> restoreLives(int amount) async {
    _lives = min(5, _lives + amount);
    await PrefsService.saveLives(_lives);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await PrefsService.saveSoundEnabled(_soundEnabled);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _selectedArenaIndex = 0;
    _currentLevel = 1;
    _lives = 5;
    _totalCorrect = 0;
    _totalWrong = 0;
    _totalLivesLost = 0;
    _arenaProgress = {0: 1, 1: 0, 2: 0, 3: 0};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_arena', 0);
    for (int i = 0; i < _arenas.length; i++) {
      await prefs.setInt('arena_progress_$i', i == 0 ? 1 : 0);
    }
    await PrefsService.saveLives(_lives);
    await _saveCurrentStats();
    notifyListeners();
  }
}
