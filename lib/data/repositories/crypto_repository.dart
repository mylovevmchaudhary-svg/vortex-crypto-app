import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/config/token_config.dart';
import '../../core/utils/validators.dart';
import '../../domain/models/crypto_models.dart';
import '../services/ads_service.dart';
import '../services/backend_api_service.dart';
import '../services/storage_service.dart';

class ActionResult {
  const ActionResult({
    required this.success,
    required this.message,
    this.awardedVtx = 0,
  });

  final bool success;
  final String message;
  final double awardedVtx;
}

/// Central repository managing user account, mining, real AdMob rewards,
/// 1B airdrop eligibility, offers, referrals, and BEP-20 wallet binding.
class CryptoRepository extends ChangeNotifier {
  CryptoRepository({
    required StorageService storageService,
    required AdsService adsService,
    BackendApiService? backendApiService,
    DateTime Function()? clock,
  })  : _storageService = storageService,
        _adsService = adsService,
        _backendApiService = backendApiService ?? BackendApiService(),
        _clock = clock ?? DateTime.now;

  static const String _storageKey = 'vortex_crypto_user_state_v2';

  final StorageService _storageService;
  final AdsService _adsService;
  final BackendApiService _backendApiService;
  final DateTime Function() _clock;

  late UserCryptoState _state;
  bool _initialized = false;

  UserCryptoState get state => _state;
  bool get isInitialized => _initialized;
  AdsService get adsService => _adsService;
  DateTime get now => _clock();

  static const List<double> dailyStreakRewards = <double>[
    25,
    50,
    75,
    100,
    150,
    250,
    500,
  ];

  static final List<AirdropRoadmapPhase> roadmapPhases = <AirdropRoadmapPhase>[
    const AirdropRoadmapPhase(
      phaseNumber: 1,
      title: 'Community Mining & Watch-to-Earn',
      subtitle:
          'Earn ${TokenConfig.coinSymbol} via 24h cloud mining, Google AdMob rewarded ads, daily streaks, and verified offers.',
      status: RoadmapPhaseStatus.active,
      targetLabel: 'LIVE NOW',
    ),
    const AirdropRoadmapPhase(
      phaseNumber: 2,
      title: '1B Coin Airdrop Snapshot & Anti-Bot Audit',
      subtitle:
          'Verify bound BEP-20 addresses, apply referral multipliers, and generate the Merkle claim tree.',
      status: RoadmapPhaseStatus.upcoming,
      targetLabel: 'PHASE 2',
    ),
    const AirdropRoadmapPhase(
      phaseNumber: 3,
      title: 'On-Chain BEP-20 Claim Portal Open',
      subtitle:
          '1,000,000,000 ${TokenConfig.coinSymbol} airdrop claimable directly on BNB Smart Chain.',
      status: RoadmapPhaseStatus.upcoming,
      targetLabel: 'PHASE 3',
    ),
    const AirdropRoadmapPhase(
      phaseNumber: 4,
      title: 'PancakeSwap DEX & CEX Launch',
      subtitle:
          'Liquidity pool deployment, BscScan verification, and public market trading launch.',
      status: RoadmapPhaseStatus.upcoming,
      targetLabel: 'TGE LAUNCH',
    ),
  ];

  Future<void> initialize() async {
    if (_initialized) return;
    final raw = await _storageService.readString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _state = UserCryptoState.fromJson(decoded);
      } catch (_) {
        _state = _buildFreshUnregisteredState();
      }
    } else {
      _state = _buildFreshUnregisteredState();
    }
    _syncCompletedMiningIfNeeded();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storageService.writeString(_storageKey, jsonEncode(_state.toJson()));
    await _backendApiService.upsertUserProfile(_state);
  }

  Future<ActionResult> registerAccount({
    required String displayName,
    required String email,
    String? sponsorCode,
  }) async {
    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedName.length < 2) {
      return const ActionResult(
        success: false,
        message: 'Please enter your full name (at least 2 characters).',
      );
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return const ActionResult(
        success: false,
        message: 'Please enter a valid email address.',
      );
    }

    final cleanSponsor = sponsorCode?.trim().toUpperCase() ?? '';
    if (cleanSponsor.isNotEmpty) {
      final err = AppValidators.validateReferralCode(cleanSponsor);
      if (err != null) {
        return ActionResult(success: false, message: err);
      }
    }

    final rng = Random();
    final suffix = (10000 + rng.nextInt(89999)).toString();
    final generatedUserId = '${TokenConfig.coinSymbol}-$suffix';
    final generatedRefCode = '${TokenConfig.coinSymbol}-$suffix';
    final currentTime = _clock();

    var startingBalance = 0.0;
    var referralEarned = 0.0;
    final txs = <WalletTransaction>[];

    if (cleanSponsor.isNotEmpty) {
      const inviteBonus = 100.0;
      startingBalance += inviteBonus;
      referralEarned += inviteBonus;
      txs.add(
        WalletTransaction(
          id: 'tx_signup_ref_${currentTime.millisecondsSinceEpoch}',
          title: 'Sponsor Invite Linked ($cleanSponsor)',
          subtitle: 'Welcome referral bonus',
          amount: inviteBonus,
          type: TransactionType.referral,
          timestamp: currentTime,
        ),
      );
    }

    _state = _buildFreshUnregisteredState().copyWith(
      isRegistered: true,
      userId: generatedUserId,
      referralCode: generatedRefCode,
      displayName: trimmedName,
      email: trimmedEmail,
      appliedSponsorCode: cleanSponsor.isEmpty ? null : cleanSponsor,
      balanceVtx: startingBalance,
      referralEarnedVtx: referralEarned,
      transactions: txs,
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message: cleanSponsor.isNotEmpty
          ? 'Account created! +100 ${TokenConfig.coinSymbol} invite bonus credited.'
          : 'Welcome to ${TokenConfig.coinName}! Start mining or watch ads to earn.',
      awardedVtx: startingBalance,
    );
  }

  Future<void> signOut() async {
    _state = _buildFreshUnregisteredState();
    await _storageService.remove(_storageKey);
    notifyListeners();
  }

  void _syncCompletedMiningIfNeeded() {
    final currentTime = _clock();
    if (_state.miningActive &&
        _state.miningSessionEnd != null &&
        currentTime.isAfter(_state.miningSessionEnd!)) {
      final pending = _state.pendingMiningSinceLastSync(currentTime);
      if (pending > 0) {
        final tx = WalletTransaction(
          id: 'tx_mine_${currentTime.millisecondsSinceEpoch}',
          title: '24h Mining Session Completed',
          subtitle: 'Auto-settled ${TokenConfig.coinSymbol} session reward',
          amount: pending,
          type: TransactionType.mining,
          timestamp: _state.miningSessionEnd!,
        );
        _state = _state.copyWith(
          balanceVtx: _state.balanceVtx + pending,
          miningEarnedVtx: _state.miningEarnedVtx + pending,
          globalAirdropDistributed: _state.globalAirdropDistributed + pending,
          miningActive: false,
          clearMiningSessionEnd: true,
          clearLastMiningSync: true,
          transactions: <WalletTransaction>[tx, ..._state.transactions],
        );
      } else {
        _state = _state.copyWith(
          miningActive: false,
          clearMiningSessionEnd: true,
          clearLastMiningSync: true,
        );
      }
    }
  }

  Future<ActionResult> startMining() async {
    final currentTime = _clock();
    _syncCompletedMiningIfNeeded();

    if (_state.miningActive) {
      return const ActionResult(
        success: false,
        message: 'Mining session is already active.',
      );
    }

    final sessionEnd =
        currentTime.add(const Duration(hours: TokenConfig.miningSessionHours));
    _state = _state.copyWith(
      miningActive: true,
      miningSessionEnd: sessionEnd,
      lastMiningSync: currentTime,
    );
    await _persist();
    notifyListeners();
    return const ActionResult(
      success: true,
      message: '24-hour mining started! Watch a rewarded ad anytime for 2x speed.',
    );
  }

  Future<ActionResult> claimPendingMining() async {
    final currentTime = _clock();
    final pending = _state.pendingMiningSinceLastSync(currentTime);
    if (pending < 0.01) {
      return const ActionResult(
        success: false,
        message: 'Mining just started — wait a few seconds before harvesting.',
      );
    }

    final sessionFinished = _state.miningSessionEnd != null &&
        !currentTime.isBefore(_state.miningSessionEnd!);
    final tx = WalletTransaction(
      id: 'tx_mine_${currentTime.millisecondsSinceEpoch}',
      title: 'Cloud Mining Harvest',
      subtitle: _state.isBoostActiveAt(currentTime)
          ? '2x Ad-Boosted Mining Claim'
          : 'Standard Mining Claim',
      amount: pending,
      type: TransactionType.mining,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      balanceVtx: _state.balanceVtx + pending,
      miningEarnedVtx: _state.miningEarnedVtx + pending,
      globalAirdropDistributed: _state.globalAirdropDistributed + pending,
      miningActive: !sessionFinished,
      clearMiningSessionEnd: sessionFinished,
      clearLastMiningSync: sessionFinished,
      lastMiningSync: sessionFinished ? null : currentTime,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message:
          'Harvested +${pending.toStringAsFixed(2)} ${TokenConfig.coinSymbol}!',
      awardedVtx: pending,
    );
  }

  Future<ActionResult> tapToEarn() async {
    if (_state.tapsToday >= TokenConfig.dailyTapLimit) {
      return const ActionResult(
        success: false,
        message:
            'Daily tap energy (${TokenConfig.dailyTapLimit}) depleted. Watch ads or complete offers to earn more!',
      );
    }

    final currentTime = _clock();
    const reward = TokenConfig.tapRewardAmount;
    final nextTapCount = _state.tapsToday + 1;

    var nextTxs = _state.transactions;
    if (nextTapCount == 1 || nextTapCount % 10 == 0) {
      nextTxs = <WalletTransaction>[
        WalletTransaction(
          id: 'tx_tap_${currentTime.millisecondsSinceEpoch}',
          title: 'Tap-to-Earn Milestone',
          subtitle: 'Tap #$nextTapCount/${TokenConfig.dailyTapLimit} today',
          amount: reward,
          type: TransactionType.tap,
          timestamp: currentTime,
        ),
        ..._state.transactions,
      ];
    }

    _state = _state.copyWith(
      balanceVtx: _state.balanceVtx + reward,
      miningEarnedVtx: _state.miningEarnedVtx + reward,
      globalAirdropDistributed: _state.globalAirdropDistributed + reward,
      tapsToday: nextTapCount,
      transactions: nextTxs,
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message: '+${reward.toStringAsFixed(0)} ${TokenConfig.coinSymbol}',
      awardedVtx: reward,
    );
  }

  Future<ActionResult> watchAndClaimAd(AdPlacement placement) async {
    if (_state.adsWatchedToday >= TokenConfig.dailyAdWatchLimit) {
      return const ActionResult(
        success: false,
        message:
            'Daily ad limit (${TokenConfig.dailyAdWatchLimit}/day) reached. Come back tomorrow!',
      );
    }

    final result = await _adsService.showRewardedAd(
      placement: placement,
      userId: _state.userId,
    );
    return claimWatchedAd(result);
  }

  Future<ActionResult> claimWatchedAd(AdRewardResult rewardResult) async {
    if (!rewardResult.completed) {
      return ActionResult(
        success: false,
        message: rewardResult.errorMessage ??
            'Ad must be watched completely to receive your reward.',
      );
    }
    if (_state.adsWatchedToday >= TokenConfig.dailyAdWatchLimit) {
      return const ActionResult(
        success: false,
        message:
            'Daily ad watch cap (${TokenConfig.dailyAdWatchLimit}/day) reached. Come back tomorrow!',
      );
    }

    final currentTime = _clock();
    DateTime? nextBoostUntil = _state.boost2xUntil;
    if (rewardResult.boostHoursGranted > 0) {
      final baseTime =
          (nextBoostUntil != null && nextBoostUntil.isAfter(currentTime))
              ? nextBoostUntil
              : currentTime;
      nextBoostUntil =
          baseTime.add(Duration(hours: rewardResult.boostHoursGranted));
    }

    final tx = WalletTransaction(
      id: 'tx_ad_${currentTime.millisecondsSinceEpoch}',
      title: rewardResult.title,
      subtitle: rewardResult.boostHoursGranted > 0
          ? '+${rewardResult.boostHoursGranted}h 2x Speed • ${rewardResult.verificationNonce}'
          : 'Verified Watch-to-Earn • ${rewardResult.verificationNonce}',
      amount: rewardResult.rewardAmount,
      type: TransactionType.adReward,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      balanceVtx: _state.balanceVtx + rewardResult.rewardAmount,
      adEarnedVtx: _state.adEarnedVtx + rewardResult.rewardAmount,
      globalAirdropDistributed:
          _state.globalAirdropDistributed + rewardResult.rewardAmount,
      totalAdsWatched: _state.totalAdsWatched + 1,
      adsWatchedToday: _state.adsWatchedToday + 1,
      boost2xUntil: nextBoostUntil,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();

    final boostText = rewardResult.boostHoursGranted > 0
        ? ' + ${rewardResult.boostHoursGranted}h 2x Mining Boost!'
        : '';
    return ActionResult(
      success: true,
      message:
          'Earned +${rewardResult.rewardAmount.toStringAsFixed(0)} ${TokenConfig.coinSymbol}$boostText',
      awardedVtx: rewardResult.rewardAmount,
    );
  }

  Future<ActionResult> claimDailyStreak() async {
    if (_state.streakClaimedToday) {
      return const ActionResult(
        success: false,
        message: 'Today\'s daily streak reward is already claimed.',
      );
    }

    final currentTime = _clock();
    final dayIndex = _state.streakDay.clamp(0, dailyStreakRewards.length - 1);
    final reward = dailyStreakRewards[dayIndex];
    final nextDay = (dayIndex + 1) % dailyStreakRewards.length;

    final tx = WalletTransaction(
      id: 'tx_streak_${currentTime.millisecondsSinceEpoch}',
      title: 'Day ${dayIndex + 1} Check-In Bonus',
      subtitle: 'Daily streak reward',
      amount: reward,
      type: TransactionType.dailyStreak,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      balanceVtx: _state.balanceVtx + reward,
      offerEarnedVtx: _state.offerEarnedVtx + reward,
      globalAirdropDistributed: _state.globalAirdropDistributed + reward,
      streakDay: nextDay,
      streakClaimedToday: true,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message:
          'Day ${dayIndex + 1} claimed! +${reward.toStringAsFixed(0)} ${TokenConfig.coinSymbol}',
      awardedVtx: reward,
    );
  }

  Future<ActionResult> completeOffer(String offerId) async {
    final index = _state.offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      return const ActionResult(success: false, message: 'Offer not found.');
    }
    final offer = _state.offers[index];
    if (offer.isCompleted) {
      return const ActionResult(
        success: false,
        message: 'This offer has already been claimed.',
      );
    }

    final currentTime = _clock();
    final updatedOffers = List<EarnOffer>.from(_state.offers);
    updatedOffers[index] = offer.copyWith(isCompleted: true);

    final tx = WalletTransaction(
      id: 'tx_offer_${offer.id}_${currentTime.millisecondsSinceEpoch}',
      title: offer.title,
      subtitle: '${offer.badgeText} • Verified task',
      amount: offer.reward,
      type: TransactionType.offer,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      balanceVtx: _state.balanceVtx + offer.reward,
      offerEarnedVtx: _state.offerEarnedVtx + offer.reward,
      globalAirdropDistributed: _state.globalAirdropDistributed + offer.reward,
      offers: updatedOffers,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message:
          'Task verified! +${offer.reward.toStringAsFixed(0)} ${TokenConfig.coinSymbol}',
      awardedVtx: offer.reward,
    );
  }

  Future<ActionResult> bindWalletAddress({
    required String address,
    required String provider,
  }) async {
    final trimmed = address.trim();
    final validationError = AppValidators.validateBep20Address(trimmed);
    if (validationError != null) {
      return ActionResult(success: false, message: validationError);
    }

    final isFirstBind = _state.boundWalletAddress == null;
    final currentTime = _clock();
    const bindBonus = 100.0;

    var nextBalance = _state.balanceVtx;
    var nextOfferEarned = _state.offerEarnedVtx;
    var nextTxs = _state.transactions;

    if (isFirstBind) {
      nextBalance += bindBonus;
      nextOfferEarned += bindBonus;
      nextTxs = <WalletTransaction>[
        WalletTransaction(
          id: 'tx_wallet_bind_${currentTime.millisecondsSinceEpoch}',
          title: 'BEP-20 Wallet Linked',
          subtitle: '$provider • Airdrop destination verified',
          amount: bindBonus,
          type: TransactionType.airdropBonus,
          timestamp: currentTime,
        ),
        ..._state.transactions,
      ];
    }

    _state = _state.copyWith(
      boundWalletAddress: trimmed,
      boundWalletProvider: provider,
      balanceVtx: nextBalance,
      offerEarnedVtx: nextOfferEarned,
      transactions: nextTxs,
    );

    await _persist();
    notifyListeners();
    return ActionResult(
      success: true,
      message: isFirstBind
          ? '$provider connected! +100 ${TokenConfig.coinSymbol} Wallet Bonus credited.'
          : 'BEP-20 Wallet updated to $provider.',
      awardedVtx: isFirstBind ? bindBonus : 0,
    );
  }

  Future<ActionResult> applySponsorReferralCode(String rawCode) async {
    if (_state.appliedSponsorCode != null) {
      return ActionResult(
        success: false,
        message: 'Invite code ${_state.appliedSponsorCode} is already linked.',
      );
    }

    final code = rawCode.trim().toUpperCase();
    final validationError = AppValidators.validateReferralCode(code);
    if (validationError != null) {
      return ActionResult(success: false, message: validationError);
    }
    if (code == _state.referralCode) {
      return const ActionResult(
        success: false,
        message: 'You cannot apply your own referral code.',
      );
    }

    final currentTime = _clock();
    const inviteBonus = 100.0;
    final tx = WalletTransaction(
      id: 'tx_sponsor_${currentTime.millisecondsSinceEpoch}',
      title: 'Referral Code Applied ($code)',
      subtitle: 'Welcome sponsor bonus',
      amount: inviteBonus,
      type: TransactionType.referral,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      appliedSponsorCode: code,
      balanceVtx: _state.balanceVtx + inviteBonus,
      referralEarnedVtx: _state.referralEarnedVtx + inviteBonus,
      globalAirdropDistributed: _state.globalAirdropDistributed + inviteBonus,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();
    return const ActionResult(
      success: true,
      message: 'Invite code linked! +100 ${TokenConfig.coinSymbol} credited.',
      awardedVtx: inviteBonus,
    );
  }

  Future<ActionResult> registerForAirdropSnapshot() async {
    if (_state.airdropRegistered) {
      return const ActionResult(
        success: false,
        message: 'You are already registered in the 1B Airdrop Snapshot!',
      );
    }
    if (_state.boundWalletAddress == null) {
      return const ActionResult(
        success: false,
        message: 'Bind your BEP-20 wallet first to lock your 1B Airdrop spot.',
      );
    }
    if (_state.totalAdsWatched < 3) {
      return const ActionResult(
        success: false,
        message: 'Watch at least 3 rewarded ads to pass Proof-of-Humanity check.',
      );
    }

    final currentTime = _clock();
    const snapshotBonus = 250.0;
    final tx = WalletTransaction(
      id: 'tx_airdrop_lock_${currentTime.millisecondsSinceEpoch}',
      title: '1B Airdrop Allocation Locked',
      subtitle: 'Snapshot priority verified (${_state.pioneerTier})',
      amount: snapshotBonus,
      type: TransactionType.airdropBonus,
      timestamp: currentTime,
    );

    _state = _state.copyWith(
      airdropRegistered: true,
      balanceVtx: _state.balanceVtx + snapshotBonus,
      offerEarnedVtx: _state.offerEarnedVtx + snapshotBonus,
      transactions: <WalletTransaction>[tx, ..._state.transactions],
    );

    await _persist();
    notifyListeners();
    return const ActionResult(
      success: true,
      message:
          'Airdrop Snapshot spot locked! +250 ${TokenConfig.coinSymbol} Pioneer Bonus added.',
      awardedVtx: snapshotBonus,
    );
  }

  Future<void> updateProfileSettings({
    String? displayName,
    String? email,
    bool? notificationsEnabled,
    bool? miningAlertsEnabled,
    bool? hapticsEnabled,
    bool? biometricLockEnabled,
  }) async {
    _state = _state.copyWith(
      displayName: displayName,
      email: email,
      notificationsEnabled: notificationsEnabled,
      miningAlertsEnabled: miningAlertsEnabled,
      hapticsEnabled: hapticsEnabled,
      biometricLockEnabled: biometricLockEnabled,
    );
    await _persist();
    notifyListeners();
  }

  UserCryptoState _buildFreshUnregisteredState() {
    return const UserCryptoState(
      isRegistered: false,
      userId: '',
      displayName: '',
      email: '',
      balanceVtx: 0.0,
      adEarnedVtx: 0.0,
      referralEarnedVtx: 0.0,
      miningEarnedVtx: 0.0,
      offerEarnedVtx: 0.0,
      totalAdsWatched: 0,
      adsWatchedToday: 0,
      tapsToday: 0,
      streakDay: 0,
      streakClaimedToday: false,
      miningActive: false,
      miningSessionEnd: null,
      lastMiningSync: null,
      boost2xUntil: null,
      boundWalletAddress: null,
      boundWalletProvider: null,
      referralCode: '',
      appliedSponsorCode: null,
      globalAirdropDistributed: 0.0,
      airdropRegistered: false,
      notificationsEnabled: true,
      miningAlertsEnabled: true,
      hapticsEnabled: true,
      biometricLockEnabled: false,
      offers: <EarnOffer>[
        EarnOffer(
          id: 'offer_tg',
          title: 'Join Official Telegram Channel',
          description:
              'Get live 1B airdrop snapshot dates and BSC contract launch alerts.',
          reward: 150,
          category: OfferCategory.social,
          badgeText: 'TELEGRAM',
          actionLabel: 'Join & Verify',
          durationLabel: '30 sec',
          actionUrl: TokenConfig.telegramUrl,
        ),
        EarnOffer(
          id: 'offer_x',
          title: 'Follow ${TokenConfig.coinName} on X',
          description:
              'Follow our official X handle for token listing announcements.',
          reward: 150,
          category: OfferCategory.social,
          badgeText: 'X / TWITTER',
          actionLabel: 'Follow & Verify',
          durationLabel: '30 sec',
          actionUrl: TokenConfig.twitterUrl,
        ),
        EarnOffer(
          id: 'offer_yt',
          title: 'Subscribe on YouTube',
          description:
              'Watch our project roadmap & tokenomics launch breakdown.',
          reward: 120,
          category: OfferCategory.ads,
          badgeText: 'YOUTUBE',
          actionLabel: 'Watch & Claim',
          durationLabel: '1 min',
          actionUrl: TokenConfig.youtubeUrl,
        ),
        EarnOffer(
          id: 'offer_bsc_ready',
          title: 'Setup BNB Smart Chain Network',
          description:
              'Ensure BNB Smart Chain (BEP-20) is enabled in your Web3 wallet.',
          reward: 200,
          category: OfferCategory.partner,
          badgeText: 'WEB3 SETUP',
          actionLabel: 'Verify Setup',
          durationLabel: '1 min',
          actionUrl: TokenConfig.explorerBaseUrl,
        ),
      ],
      referrals: <ReferralMember>[],
      transactions: <WalletTransaction>[],
    );
  }
}
