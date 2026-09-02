import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'AI_API_KEY', defaultValue: '')
  static final String aiApiKey = _Env.aiApiKey;

  @EnviedField(varName: 'AI_API_URL', defaultValue: 'https://openrouter.ai/api/v1/chat/completions')
  static final String aiApiUrl = _Env.aiApiUrl;

  @EnviedField(varName: 'AI_MODEL', defaultValue: 'openrouter/free')
  static final String aiModel = _Env.aiModel;

  @EnviedField(varName: 'NVIDIA_API_KEY', defaultValue: '')
  static final String nvidiaApiKey = _Env.nvidiaApiKey;

  @EnviedField(varName: 'NVIDIA_API_URL', defaultValue: 'https://integrate.api.nvidia.com/v1/chat/completions')
  static final String nvidiaApiUrl = _Env.nvidiaApiUrl;

  @EnviedField(varName: 'NVIDIA_MODEL', defaultValue: 'nvidia/nemotron-3.5-lightning-30b-a3b')
  static final String nvidiaModel = _Env.nvidiaModel;

  @EnviedField(varName: 'CURRENCY_BASE_URL', defaultValue: 'https://api.currencybeacon.com/v1')
  static final String currencyBaseUrl = _Env.currencyBaseUrl;

  @EnviedField(varName: 'CURRENCY_TOKEN', defaultValue: '')
  static final String currencyToken = _Env.currencyToken;

  @EnviedField(varName: 'ADMOB_BANNER_ANDROID', defaultValue: '')
  static final String admobBannerAndroid = _Env.admobBannerAndroid;

  @EnviedField(varName: 'ADMOB_BANNER_IOS', defaultValue: '')
  static final String admobBannerIos = _Env.admobBannerIos;

  @EnviedField(varName: 'ADMOB_INTERSTITIAL_ANDROID', defaultValue: '')
  static final String admobInterstitialAndroid = _Env.admobInterstitialAndroid;

  @EnviedField(varName: 'ADMOB_INTERSTITIAL_IOS', defaultValue: '')
  static final String admobInterstitialIos = _Env.admobInterstitialIos;
}
