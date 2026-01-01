import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String keyLevel = 'user_level';
  static const String keyLives = 'user_lives';
  static const String keyHighestLevel = 'highest_level';
  static const String keyTotalCorrect = 'total_correct';
  static const String keyTotalWrong = 'total_wrong';
  static const String keyTotalLivesLost = 'total_lives_lost';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyCoins = 'user_coins';

  static const String keyTutorialShown = 'tutorial_shown';



  static Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLevel, level);
  }

  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLevel) ?? 1;
  }

  static Future<void> saveLives(int lives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLives, lives);
  }

  static Future<int> getLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLives) ?? 5;
  }

  static Future<void> saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyHighestLevel, level);
  }

  static Future<int> getHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyHighestLevel) ?? 1;
  }

  static Future<void> saveStats({required int correct, required int wrong, required int livesLost}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTotalCorrect, correct);
    await prefs.setInt(keyTotalWrong, wrong);
    await prefs.setInt(keyTotalLivesLost, livesLost);
  }

  static Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'correct': prefs.getInt(keyTotalCorrect) ?? 0,
      'wrong': prefs.getInt(keyTotalWrong) ?? 0,
      'livesLost': prefs.getInt(keyTotalLivesLost) ?? 0,
    };
  }

  static Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySoundEnabled, enabled);
  }

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySoundEnabled) ?? true;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCoins, coins);
  }

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCoins) ?? 0;
  }

  static Future<void> saveTutorialShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialShown, shown);
  }

  static Future<bool> isTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyTutorialShown) ?? false;
  }

  static const String keyShareCount = 'share_count';

  static Future<void> saveShareCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyShareCount, count);
  }

  static Future<int> getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyShareCount) ?? 0;
  }

  static const String keyLastRewardDate = 'last_reward_date';

  static Future<void> saveLastRewardDate(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLastRewardDate, timestamp);
  }

  static Future<int> getLastRewardDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLastRewardDate) ?? 0;
  }
}

