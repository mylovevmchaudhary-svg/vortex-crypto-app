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
        adsService: TestAdsService(),
        clock: () => currentTime,
      );
      await repository.initialize();
    });

    test('starts unregistered with zero balance until account is created',
        () async {
      expect(repository.state.isRegistered, isFalse);
      expect(repository.state.balanceVtx, 0.0);
      expect(repository.state.referrals, isEmpty);
      expect(repository.state.transactions, isEmpty);

      final reg = await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      expect(reg.success, isTrue);
      expect(repository.state.isRegistered, isTrue);
      expect(repository.state.displayName, 'Mukesh Chaudhary');
      expect(repository.state.balanceVtx, 0.0);
    });

    test('credits tap-to-earn and enforces daily tap cap', () async {
      await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      final res = await repository.tapToEarn();
      expect(res.success, isTrue);
      expect(repository.state.balanceVtx, TokenConfig.tapRewardAmount);

      for (var i = 1; i < TokenConfig.dailyTapLimit; i++) {
        await repository.tapToEarn();
      }
      final capResult = await repository.tapToEarn();
      expect(capResult.success, isFalse);
    });

    test('starts cloud mining, accrues over time, and claims reward', () async {
      await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      final startRes = await repository.startMining();
      expect(startRes.success, isTrue);
      expect(repository.state.miningActive, isTrue);

      currentTime = currentTime.add(const Duration(hours: 2));
      final pending = repository.state.pendingMiningSinceLastSync(currentTime);
      expect(pending, greaterThan(20.0));

      final claimRes = await repository.claimPendingMining();
      expect(claimRes.success, isTrue);
      expect(repository.state.balanceVtx, closeTo(pending, 0.001));
    });

    test('awards watched ad coins and activates 2x mining boost', () async {
      await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      final outcome = await repository.watchAndClaimAd(
        AdPlacement.miningBoost2x,
      );

      expect(outcome.success, isTrue);
      expect(repository.state.balanceVtx, 25.0);
      expect(repository.state.isBoostActiveAt(currentTime), isTrue);
    });

    test('requires BEP-20 wallet and 3 ads before locking 1B airdrop spot',
        () async {
      await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      final failNoWallet = await repository.registerForAirdropSnapshot();
      expect(failNoWallet.success, isFalse);

      final bindRes = await repository.bindWalletAddress(
        address: '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        provider: 'MetaMask',
      );
      expect(bindRes.success, isTrue);

      for (var i = 0; i < 3; i++) {
        await repository.watchAndClaimAd(AdPlacement.watchAndEarn);
      }

      final lockRes = await repository.registerForAirdropSnapshot();
      expect(lockRes.success, isTrue);
      expect(repository.state.airdropRegistered, isTrue);
    });

    test('persists state across repository re-initialization', () async {
      await repository.registerAccount(
        displayName: 'Mukesh Chaudhary',
        email: 'mukesh@example.com',
      );
      await repository.completeOffer('offer_tg');
      final savedBalance = repository.state.balanceVtx;

      final restoredRepo = CryptoRepository(
        storageService: storage,
        adsService: TestAdsService(),
        clock: () => currentTime,
      );
      await restoredRepo.initialize();
      expect(restoredRepo.state.isRegistered, isTrue);
      expect(restoredRepo.state.balanceVtx, savedBalance);
      expect(
        restoredRepo.state.offers
            .firstWhere((o) => o.id == 'offer_tg')
            .isCompleted,
        isTrue,
      );
    });
  });
}
