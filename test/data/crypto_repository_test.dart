import 'package:flutter_test/flutter_test.dart';
import 'package:vortex_crypto_app/core/config/token_config.dart';
import 'package:vortex_crypto_app/data/repositories/crypto_repository.dart';
import 'package:vortex_crypto_app/data/services/ads_service.dart';
import 'package:vortex_crypto_app/data/services/storage_service.dart';

void main() {
  group('CryptoRepository', () {
    late DateTime currentTime;
    late InMemoryStorageService storage;
    late CryptoRepository repository;

    setUp(() async {
      currentTime = DateTime(2026, 11, 25, 10, 0, 0);
      storage = InMemoryStorageService();
      repository = CryptoRepository(
        storageService: storage,
        adsService: SimulatedRewardedAdsService(),
        clock: () => currentTime,
      );
      await repository.initialize();
    });

    test('credits tap-to-earn and enforces daily tap cap', () async {
      final startBalance = repository.state.balanceVtx;
      final res = await repository.tapToEarn();
      expect(res.success, isTrue);
      expect(repository.state.balanceVtx, startBalance + TokenConfig.tapRewardAmount);

      for (var i = 1; i < TokenConfig.dailyTapLimit; i++) {
        await repository.tapToEarn();
      }
      final capResult = await repository.tapToEarn();
      expect(capResult.success, isFalse);
    });

    test('starts cloud mining, accrues over time, and claims reward', () async {
      final startRes = await repository.startMining();
      expect(startRes.success, isTrue);
      expect(repository.state.miningActive, isTrue);

      currentTime = currentTime.add(const Duration(hours: 2));
      final pending = repository.state.pendingMiningSinceLastSync(currentTime);
      expect(pending, greaterThan(20.0));

      final beforeBalance = repository.state.balanceVtx;
      final claimRes = await repository.claimPendingMining();
      expect(claimRes.success, isTrue);
      expect(repository.state.balanceVtx, closeTo(beforeBalance + pending, 0.001));
    });

    test('awards watched ad coins and activates 2x mining boost', () async {
      final adResult = repository.adsService.generateRewardForPlacement(
        AdPlacement.miningBoost2x,
      );
      final beforeBalance = repository.state.balanceVtx;
      final outcome = await repository.claimWatchedAd(adResult);

      expect(outcome.success, isTrue);
      expect(repository.state.balanceVtx, beforeBalance + adResult.rewardAmount);
      expect(repository.state.isBoostActiveAt(currentTime), isTrue);
    });

    test('requires BEP-20 wallet and 3 ads before locking 1B airdrop spot', () async {
      final failNoWallet = await repository.registerForAirdropSnapshot();
      expect(failNoWallet.success, isFalse);

      final bindRes = await repository.bindWalletAddress(
        address: '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        provider: 'MetaMask',
      );
      expect(bindRes.success, isTrue);

      // Starter state has 1 ad watched; watch 2 more to hit >= 3 ads
      for (var i = 0; i < 2; i++) {
        final ad = repository.adsService
            .generateRewardForPlacement(AdPlacement.watchAndEarn);
        await repository.claimWatchedAd(ad);
      }

      final lockRes = await repository.registerForAirdropSnapshot();
      expect(lockRes.success, isTrue);
      expect(repository.state.airdropRegistered, isTrue);
    });

    test('persists state across repository re-initialization', () async {
      await repository.completeOffer('offer_tg');
      final savedBalance = repository.state.balanceVtx;

      final restoredRepo = CryptoRepository(
        storageService: storage,
        adsService: SimulatedRewardedAdsService(),
        clock: () => currentTime,
      );
      await restoredRepo.initialize();
      expect(restoredRepo.state.balanceVtx, savedBalance);
      expect(
        restoredRepo.state.offers.firstWhere((o) => o.id == 'offer_tg').isCompleted,
        isTrue,
      );
    });
  });
}
