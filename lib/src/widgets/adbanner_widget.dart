import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CustomAdBanner extends StatefulWidget {
  final String? amount;
  final Function? acction;

  const CustomAdBanner({Key? key, this.amount, this.acction}) : super(key: key);

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
  Widget build(BuildContext context) {
    return SizedBox(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  initBannerAd() {
    bannerAd = new BannerAd(
        size: AdSize.banner,
        adUnitId: "",
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            print(error);
          },
        ),
        request: const AdRequest());
    bannerAd.load();
  }
}
