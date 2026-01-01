import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAdViewed(String adType) async {
    try {
      await _analytics.logEvent(
        name: 'ad_viewed',
        parameters: {
          'ad_type': adType,
        },
      );
      debugPrint('Analytics: Ad Viewed ($adType)');
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  static Future<void> logLevelComplete(int levelIndex, String arenaName) async {
    try {
        await _analytics.logLevelEnd(
            levelName: 'Level $levelIndex', 
            success: 1
        );
         await _analytics.logEvent(
            name: 'arena_progress',
            parameters: {
                'arena': arenaName,
                'level': levelIndex
            }
        );
    } catch (e) {
        debugPrint('Analytics Error: $e');
    }
  }
}
