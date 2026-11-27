import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
    this.errorMessage,
  });

  final bool completed;
  final double rewardAmount;
  final int boostHoursGranted;
  final String verificationNonce;
  final String title;
  final String? errorMessage;
}

/// Service interface for Rewarded Video Ads.
abstract class AdsService {
  Future<void> initialize();
  Future<AdRewardResult> showRewardedAd({
    required AdPlacement placement,
    required String userId,
  });
}

/// Real Google AdMob implementation for Android & iOS mobile devices.
///
/// Uses [TokenConfig.androidRewardedAdUnitId] with Server-Side Verification
/// customData so ad impressions can be verified by your Supabase Edge Function.
class AdMobAdsService implements AdsService {
  AdMobAdsService({Random? random}) : _random = random ?? Random();

  final Random _random;
  bool _initialized = false;

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (_initialized || !_isMobilePlatform) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  @override
  Future<AdRewardResult> showRewardedAd({
    required AdPlacement placement,
    required String userId,
  }) async {
    if (!_isMobilePlatform) {
      return const AdRewardResult(
        completed: false,
        rewardAmount: 0,
        boostHoursGranted: 0,
        verificationNonce: '',
        title: 'Rewarded Video Ad',
        errorMessage:
            'Rewarded video ads require an Android or iOS mobile device.',
      );
    }

    await initialize();
    final completer = Completer<AdRewardResult>();
    final nonce = _generateNonce();
    final rewardValue = _rewardForPlacement(placement);
    final boostHours =
        placement == AdPlacement.miningBoost2x ? TokenConfig.boostHoursPerAd : 0;
    final adTitle = _titleForPlacement(placement);

    await RewardedAd.load(
      adUnitId: TokenConfig.androidRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          var rewardEarned = false;

          ad.setServerSideOptions(
            ServerSideVerificationOptions(
              userId: userId,
              customData: '${placement.name}:$nonce',
            ),
          );

          ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
            onAdDismissedFullScreenContent: (RewardedAd loadedAd) {
              loadedAd.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  AdRewardResult(
                    completed: rewardEarned,
                    rewardAmount: rewardEarned ? rewardValue : 0,
                    boostHoursGranted: rewardEarned ? boostHours : 0,
                    verificationNonce: nonce,
                    title: adTitle,
                    errorMessage: rewardEarned
                        ? null
                        : 'Ad closed before completion. Watch the full ad to earn rewards.',
                  ),
                );
              }
            },
            onAdFailedToShowFullScreenContent:
                (RewardedAd loadedAd, AdError error) {
              loadedAd.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  AdRewardResult(
                    completed: false,
                    rewardAmount: 0,
                    boostHoursGranted: 0,
                    verificationNonce: nonce,
                    title: adTitle,
                    errorMessage:
                        'Unable to play ad right now (${error.message}). Please try again.',
                  ),
                );
              }
            },
          );

          ad.show(
            onUserEarnedReward: (AdWithoutView adView, RewardItem item) {
              rewardEarned = true;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (!completer.isCompleted) {
            completer.complete(
              AdRewardResult(
                completed: false,
                rewardAmount: 0,
                boostHoursGranted: 0,
                verificationNonce: nonce,
                title: adTitle,
                errorMessage:
                    'No ad available right now. Check your internet connection and retry.',
              ),
            );
          }
        },
      ),
    );

    return completer.future;
  }

  String _generateNonce() {
    final hex = _random
        .nextInt(0x7fffffff)
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();
    return 'ADMOB-$hex';
  }

  String _titleForPlacement(AdPlacement placement) {
    return switch (placement) {
      AdPlacement.watchAndEarn => 'Rewarded Video Ad',
      AdPlacement.miningBoost2x => '2x Mining Speed Boost Ad',
      AdPlacement.mysteryCrate => 'Mystery Ad Crate',
    };
  }

  double _rewardForPlacement(AdPlacement placement) {
    return switch (placement) {
      AdPlacement.watchAndEarn => TokenConfig.standardAdReward,
      AdPlacement.miningBoost2x => 25.0,
      AdPlacement.mysteryCrate => _randomMysteryAmount(),
    };
  }

  double _randomMysteryAmount() {
    final min = TokenConfig.mysteryAdMinReward.toInt();
    final max = TokenConfig.mysteryAdMaxReward.toInt();
    final steps = ((max - min) ~/ 5) + 1;
    return (min + (_random.nextInt(steps) * 5)).toDouble();
  }
}

/// Lightweight deterministic [AdsService] used strictly in automated tests.
class TestAdsService implements AdsService {
  TestAdsService({this.shouldComplete = true});

  final bool shouldComplete;

  @override
  Future<void> initialize() async {}

  @override
  Future<AdRewardResult> showRewardedAd({
    required AdPlacement placement,
    required String userId,
  }) async {
    return AdRewardResult(
      completed: shouldComplete,
      rewardAmount: placement == AdPlacement.miningBoost2x
          ? 25.0
          : TokenConfig.standardAdReward,
      boostHoursGranted: placement == AdPlacement.miningBoost2x
          ? TokenConfig.boostHoursPerAd
          : 0,
      verificationNonce: 'TEST-SSV-001',
      title: 'Rewarded Video Ad',
      errorMessage: shouldComplete ? null : 'Ad skipped',
    );
  }
}
