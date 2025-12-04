import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/constants.dart';

class AdMobService {
  static NativeAd createNativeAd({required Function(Ad) onLoaded}) {
    return NativeAd(
      adUnitId: AppConstants.nativeAdUnitId, // This is now defined
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad Failed: $error');
        },
      ),
    );
  }
}