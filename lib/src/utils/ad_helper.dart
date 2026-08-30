import 'dart:io';
import 'package:mortgageloan/src/config/env.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return Env.admobBannerAndroid;
    } else if (Platform.isIOS) {
      return Env.admobBannerIos;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return Env.admobInterstitialAndroid;
    } else if (Platform.isIOS) {
      return Env.admobInterstitialIos;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
