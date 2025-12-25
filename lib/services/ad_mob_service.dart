import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  static const String androidRewardedUnitId = 'ca-app-pub-7086602185948470/5856672693';
  // static const String iosRewardedUnitId = 'ca-app-pub-7086602185948470/5113834023';

  RewardedAd? _rewardedAd;

  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool isRewardedLoaded = false;
  bool _isInitialized = false;
  int _retryCount = 0;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) return;
    } catch (_) {
      return; // No internet, skip initialization
    }

    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadRewardedAd();
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return androidRewardedUnitId;
    } 
    else {
      return androidRewardedUnitId;
    }
  }

  bool _isAdLoading = false;
  
  Future<void> loadRewardedAd() async {
    if (isRewardedLoaded || _isAdLoading) return;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) return;
    } catch (_) {
      return; // No internet, skip loading to preserve match rate
    }
    
    _isAdLoading = true;
    isRewardedLoaded = false;
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedLoaded = true;
          _isAdLoading = false;
          _retryCount = 0;
        },
        onAdFailedToLoad: (err) {
          isRewardedLoaded = false;
          _isAdLoading = false;
          _retryCount++;
          if (_retryCount < 10) {
            Future.delayed(Duration(seconds: min(30, 5 * _retryCount)), () => loadRewardedAd());
          }
        },
      ),
    );
  }

  void showRewardedAd({required Function onUserEarnedReward, required Function onAdDismissed}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd();
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          loadRewardedAd();
          onAdDismissed();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward();
      });
    } else {
      onAdDismissed();
    }
  }
}
