import 'dart:async';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'analytics_service.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static const String androidRewardedUnitId = 'ca-app-pub-7086602185948470/5856672693';
  // static const String iosRewardedUnitId = 'ca-app-pub-7086602185948470/5113834023';

  RewardedAd? _rewardedAd;

  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool isRewardedLoaded = false;
  bool _isInitialized = false;
  bool _isLoadingAd = false;
  int _retryCount = 0;
  Timer? _retryTimer;
  StreamSubscription? _connectivitySubscription;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Check initial connectivity
    final results = await Connectivity().checkConnectivity();
    if (results.any((result) => result != ConnectivityResult.none)) {
      await _actualInit();
    } else {
      debugPrint('AdMobService: Offline at startup. Deferring initialization.');
    }

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      
      if (hasConnection) {
        if (!_isInitialized) {
          debugPrint('AdMobService: Online detected. Initializing AdMob.');
          _actualInit();
        } else if (!isRewardedLoaded && !_isLoadingAd) {
          debugPrint('AdMobService: Online detected. Loading ad.');
          loadRewardedAd();
        }
      } else {
        debugPrint('AdMobService: Offline detected. Cancelling any pending ad loads.');
        _cancelRetry();
      }
    });
  }

  Future<void> _actualInit() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMobService: SDK Initialized.');
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMobService: Initialization error: $e');
    }
  }

  Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return androidRewardedUnitId;
    } 
    else {
      return androidRewardedUnitId;
    }
  }

  void loadRewardedAd() async {
    if (!_isInitialized) return;
    if (_isLoadingAd) return;
    if (isRewardedLoaded) return;
    
    // Only attempt load if online
    if (!await isConnected()) {
      debugPrint('AdMobService: Skipping load as offline.');
      return;
    }
    
    _isLoadingAd = true;
    isRewardedLoaded = false;
    
    debugPrint('AdMobService: Loading Rewarded Ad...');
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdMobService: Ad loaded successfully.');
          _rewardedAd = ad;
          isRewardedLoaded = true;
          _isLoadingAd = false;
          _retryCount = 0;
        },
        onAdFailedToLoad: (err) {
          debugPrint('AdMobService: Ad failed to load: ${err.message}');
          _rewardedAd = null;
          isRewardedLoaded = false;
          _isLoadingAd = false;
          _scheduleRetry();
        },
      ),
    );
  }

  void _scheduleRetry() async {
    _cancelRetry();
    
    if (!await isConnected()) return; // Don't schedule if offline
    
    _retryCount++;
    if (_retryCount > 10) return; // Cap retries

    // Exponential backoff
    final delaySeconds = min(60, pow(2, _retryCount).toInt()); 
    debugPrint('AdMobService: Retrying ad load in $delaySeconds seconds (Attempt $_retryCount)');
    
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      loadRewardedAd();
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void showRewardedAd({required Function onUserEarnedReward, required Function onAdDismissed}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          isRewardedLoaded = false;
          loadRewardedAd();
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _rewardedAd = null;
          isRewardedLoaded = false;
          loadRewardedAd();
          onAdDismissed();
        },
      );
      _rewardedAd?.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        AnalyticsService.logAdViewed('rewarded');
        onUserEarnedReward();
      },
    );
    } else {
      onAdDismissed();
      loadRewardedAd(); // Try to load one if it was missing
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _cancelRetry();
  }
}
