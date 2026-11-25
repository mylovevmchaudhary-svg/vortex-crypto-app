import 'dart:math';

import '../../core/config/token_config.dart';

enum AdPlacement {
  watchAndEarn,
  miningBoost2x,
  mysteryCrate,
}

class AdRewardResult {
  const AdRewardResult({
    required this.completed,
    required this.rewardAmount,
    required this.boostHoursGranted,
    required this.verificationNonce,
    required this.title,
  });

  final bool completed;
  final double rewardAmount;
  final int boostHoursGranted;
  final String verificationNonce;
  final String title;
}

/// Service interface for Rewarded Video Ads.
///
/// Swap [SimulatedRewardedAdsService] with an implementation backed by
/// `google_mobile_ads` (`RewardedAd.load` + AdMob SSV customData) for
/// production Play Store builds. See `docs/LAUNCH_ROADMAP.md`.
abstract class AdsService {
  AdRewardResult generateRewardForPlacement(AdPlacement placement);
}

class SimulatedRewardedAdsService implements AdsService {
  SimulatedRewardedAdsService({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  AdRewardResult generateRewardForPlacement(AdPlacement placement) {
    final nonceHex =
        _random.nextInt(0x7fffffff).toRadixString(16).padLeft(8, '0').toUpperCase();
    final nonce = 'SSV-$nonceHex';

    return switch (placement) {
      AdPlacement.watchAndEarn => AdRewardResult(
          completed: true,
          rewardAmount: TokenConfig.standardAdReward,
          boostHoursGranted: 0,
          verificationNonce: nonce,
          title: 'Rewarded Video Ad',
        ),
      AdPlacement.miningBoost2x => AdRewardResult(
          completed: true,
          rewardAmount: 25.0,
          boostHoursGranted: TokenConfig.boostHoursPerAd,
          verificationNonce: nonce,
          title: '2x Mining Speed Boost Ad',
        ),
      AdPlacement.mysteryCrate => AdRewardResult(
          completed: true,
          rewardAmount: _randomMysteryAmount(),
          boostHoursGranted: 0,
          verificationNonce: nonce,
          title: 'Mystery Ad Crate',
        ),
    };
  }

  double _randomMysteryAmount() {
    final min = TokenConfig.mysteryAdMinReward.toInt();
    final max = TokenConfig.mysteryAdMaxReward.toInt();
    final steps = ((max - min) ~/ 5) + 1;
    return (min + (_random.nextInt(steps) * 5)).toDouble();
  }
}
