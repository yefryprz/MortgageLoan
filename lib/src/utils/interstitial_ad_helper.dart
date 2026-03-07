import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:flutter/foundation.dart';
import 'ad_helper.dart';

class InterstitialAdHelper {
  final String _adCountKey;
  final int _adFrequency;
  InterstitialAd? _interstitialAd;
  final LoanData _loanRepo = LoanData();

  InterstitialAdHelper({required String adCountKey, int adFrequency = 4})
      : _adCountKey = adCountKey,
        _adFrequency = adFrequency;

  void load() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              _loanRepo.resetAdCount(_adCountKey);
              load(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              load();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load an interstitial ad: ${err.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> show() async {
    if (_interstitialAd == null) return;
    try {
      await _interstitialAd!.show();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      load();
    }
  }

  Future<void> handleAdDetailNavigation(void Function() onNavigate) async {
    onNavigate();
    int adCount = await _loanRepo.getAdCount(_adCountKey);
    if (adCount >= _adFrequency) {
      if (_interstitialAd != null) {
        await show();
      } else {
        _loanRepo.resetAdCount(_adCountKey);
      }
    } else {
      _loanRepo.AdCountUp(_adCountKey);
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
