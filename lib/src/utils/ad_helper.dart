import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.get('ADMOB_BANNER_ANDROID', fallback: '');
    } else if (Platform.isIOS) {
      return dotenv.get('ADMOB_BANNER_IOS', fallback: '');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.get('ADMOB_INTERSTITIAL_ANDROID', fallback: '');
    } else if (Platform.isIOS) {
      return dotenv.get('ADMOB_INTERSTITIAL_IOS', fallback: '');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
