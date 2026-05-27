import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _interstitialShownThisLaunch = false;
  InterstitialAd? _interstitialAd;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (!isSupported || _initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      await _loadInterstitial();
    } catch (_) {
      _initialized = false;
    }
  }

  String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppConstants.iosBannerAdUnitId;
    }
    return AppConstants.androidBannerAdUnitId;
  }

  String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppConstants.iosInterstitialAdUnitId;
    }
    return AppConstants.androidInterstitialAdUnitId;
  }

  Future<void> _loadInterstitial() async {
    if (!isSupported || !_initialized) return;
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> showAppOpenInterstitialOnce() async {
    if (!isSupported || !_initialized || _interstitialShownThisLaunch) return;
    _interstitialShownThisLaunch = true;
    final ad = _interstitialAd;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
    );
    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
    } finally {
      _interstitialAd = null;
    }
  }
}
