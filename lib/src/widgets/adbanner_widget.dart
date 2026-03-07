import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mortgageloan/src/utils/ad_helper.dart';

class CustomAdBanner extends StatefulWidget {
  const CustomAdBanner({Key? key}) : super(key: key);

  @override
  _CustomAdBannerState createState() => _CustomAdBannerState();
}

class _CustomAdBannerState extends State<CustomAdBanner> {
  late BannerAd bannerAd;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoaded
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(ad: bannerAd),
            )
          : const SizedBox(height: 50),
    );
  }

  initBannerAd() {
    bannerAd = new BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('Ad failed: $error');
          },
        ),
        request: const AdRequest());
    bannerAd.load();
  }
}
