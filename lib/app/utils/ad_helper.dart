import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static String get bannerAdUnitId {
    return 'ca-app-pub-5034042007398788/3542221736';
  }

  static String get interstitialAdUnitId {
    return 'ca-app-pub-5034042007398788/4095892136';
  }

  static Future<void> initialize() async {
    // Set child-directed treatment and content rating
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        maxAdContentRating: MaxAdContentRating.g, // G = General audiences
      ),
    );

    // Then initialize Mobile Ads SDK
    await MobileAds.instance.initialize();
  }

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;
  static bool _isLoadingInterstitial = false;

  static AdRequest get adRequest {
    return const AdRequest(
      // Request child-directed treatment
      httpTimeoutMillis: 30000, // 30 second timeout
    );
  }

  static Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdReady || _isLoadingInterstitial) {
      return;
    }
    try {
      _isLoadingInterstitial = true;
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;

            // Set up the full screen content callback immediately when ad loads
            _interstitialAd
                ?.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _isInterstitialAdReady = false;
                _isLoadingInterstitial = false;
                loadInterstitialAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Ad failed to show: $error');
                ad.dispose();
                _isInterstitialAdReady = false;
                _isLoadingInterstitial = false;
                loadInterstitialAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                // Ad showed successfully
              },
            );

            _isInterstitialAdReady = true;
            _isLoadingInterstitial = false;
            print('Interstitial ad loaded.');
          },
          onAdFailedToLoad: (error) {
            print('Interstitial ad failed to load: $error');
            _isInterstitialAdReady = false;
            _isLoadingInterstitial = false;
          },
        ),
      );
    } catch (e) {
      print('Ad loading failed: $e');
      _isInterstitialAdReady = false;
      _isLoadingInterstitial = false;
    }
  }

  static Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady) {
      print('Interstitial ad not ready yet.');
      return;
    }

    await _interstitialAd?.show();
  }

  static void dispose() {
    _interstitialAd?.dispose();
  }
}
