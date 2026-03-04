import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4574158711047577/3296197854';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4574158711047577/5477839021';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4574158711047577/2851708247';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4574158711047577/4568082033';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
