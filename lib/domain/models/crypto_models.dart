import '../../core/config/token_config.dart';

enum TransactionType {
  mining,
  adReward,
  dailyStreak,
  offer,
  referral,
  tap,
  airdropBonus,
}

enum OfferCategory {
  ads,
  social,
  partner,
}

enum RoadmapPhaseStatus {
  completed,
  active,
  upcoming,
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.status = 'Verified',
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final String status;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? TransactionType.mining.name;
    final parsedType = TransactionType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => TransactionType.mining,
    );
    return WalletTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: parsedType,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'Verified',
    );
  }
}

class EarnOffer {
  const EarnOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.category,
    required this.badgeText,
    required this.actionLabel,
    required this.durationLabel,
    this.actionUrl,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final double reward;
  final OfferCategory category;
  final String badgeText;
  final String actionLabel;
  final String durationLabel;
  final String? actionUrl;
  final bool isCompleted;

  EarnOffer copyWith({bool? isCompleted}) {
    return EarnOffer(
      id: id,
      title: title,
      description: description,
      reward: reward,
      category: category,
      badgeText: badgeText,
      actionLabel: actionLabel,
      durationLabel: durationLabel,
      actionUrl: actionUrl,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'reward': reward,
        'category': category.name,
        'badgeText': badgeText,
        'actionLabel': actionLabel,
        'durationLabel': durationLabel,
        'actionUrl': actionUrl,
        'isCompleted': isCompleted,
      };

  factory EarnOffer.fromJson(Map<String, dynamic> json) {
    final catName = json['category'] as String? ?? OfferCategory.partner.name;
    final parsedCategory = OfferCategory.values.firstWhere(
      (e) => e.name == catName,
      orElse: () => OfferCategory.partner,
    );
    return EarnOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: (json['reward'] as num).toDouble(),
      category: parsedCategory,
      badgeText: json['badgeText'] as String,
      actionLabel: json['actionLabel'] as String,
      durationLabel: json['durationLabel'] as String,
      actionUrl: json['actionUrl'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class ReferralMember {
  const ReferralMember({
    required this.id,
    required this.displayName,
    required this.tier,
    required this.isActiveMiner,
    required this.contributedVtx,
    required this.joinedAt,
  });

  final String id;
  final String displayName;
  final int tier;
  final bool isActiveMiner;
  final double contributedVtx;
  final DateTime joinedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        'tier': tier,
        'isActiveMiner': isActiveMiner,
        'contributedVtx': contributedVtx,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory ReferralMember.fromJson(Map<String, dynamic> json) {
    return ReferralMember(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      tier: (json['tier'] as num).toInt(),
      isActiveMiner: json['isActiveMiner'] as bool? ?? true,
      contributedVtx: (json['contributedVtx'] as num).toDouble(),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

class AirdropEligibilityItem {
  const AirdropEligibilityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.multiplierBonus,
    required this.isMet,
    required this.targetTabIndex,
  });

  final String id;
  final String title;
  final String subtitle;
  final String multiplierBonus;
  final bool isMet;
  final int targetTabIndex;
}

class AirdropRoadmapPhase {
  const AirdropRoadmapPhase({
    required this.phaseNumber,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.targetLabel,
  });

  final int phaseNumber;
  final String title;
  final String subtitle;
  final RoadmapPhaseStatus status;
  final String targetLabel;
}

class UserCryptoState {
  const UserCryptoState({
    required this.isRegistered,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.balanceVtx,
    required this.adEarnedVtx,
    required this.referralEarnedVtx,
    required this.miningEarnedVtx,
    required this.offerEarnedVtx,
    required this.totalAdsWatched,
    required this.adsWatchedToday,
    required this.tapsToday,
    required this.streakDay,
    required this.streakClaimedToday,
    required this.miningActive,
    required this.miningSessionEnd,
    required this.lastMiningSync,
    required this.boost2xUntil,
    required this.boundWalletAddress,
    required this.boundWalletProvider,
    required this.referralCode,
    required this.appliedSponsorCode,
    required this.globalAirdropDistributed,
    required this.airdropRegistered,
    required this.notificationsEnabled,
    required this.miningAlertsEnabled,
    required this.hapticsEnabled,
    required this.biometricLockEnabled,
    required this.offers,
    required this.referrals,
    required this.transactions,
  });

  final bool isRegistered;
  final String userId;
  final String displayName;
  final String email;
  final double balanceVtx;
  final double adEarnedVtx;
  final double referralEarnedVtx;
  final double miningEarnedVtx;
  final double offerEarnedVtx;
  final int totalAdsWatched;
  final int adsWatchedToday;
  final int tapsToday;
  final int streakDay;
  final bool streakClaimedToday;
  final bool miningActive;
  final DateTime? miningSessionEnd;
  final DateTime? lastMiningSync;
  final DateTime? boost2xUntil;
  final String? boundWalletAddress;
  final String? boundWalletProvider;
  final String referralCode;
  final String? appliedSponsorCode;
  final double globalAirdropDistributed;
  final bool airdropRegistered;
  final bool notificationsEnabled;
  final bool miningAlertsEnabled;
  final bool hapticsEnabled;
  final bool biometricLockEnabled;
  final List<EarnOffer> offers;
  final List<ReferralMember> referrals;
  final List<WalletTransaction> transactions;

  bool isBoostActiveAt(DateTime now) {
    final expiry = boost2xUntil;
    return expiry != null && expiry.isAfter(now);
  }

  double currentHourlyRate(DateTime now) {
    final activeFriends = referrals.where((r) => r.isActiveMiner).length;
    final friendBonus = activeFriends * 1.5;
    final baseWithTeam = TokenConfig.baseMiningRatePerHour + friendBonus;
    return isBoostActiveAt(now) ? baseWithTeam * 2.0 : baseWithTeam;
  }

  double pendingMiningSinceLastSync(DateTime now) {
    if (!miningActive || lastMiningSync == null || miningSessionEnd == null) {
      return 0;
    }
    final effectiveNow =
        now.isAfter(miningSessionEnd!) ? miningSessionEnd! : now;
    final seconds = effectiveNow.difference(lastMiningSync!).inSeconds;
    if (seconds <= 0) return 0;
    return (currentHourlyRate(now) / 3600.0) * seconds;
  }

  double get globalPoolProgress =>
      (globalAirdropDistributed / TokenConfig.airdropPoolTotal).clamp(0.0, 1.0);

  int get completedOffersCount =>
      offers.where((offer) => offer.isCompleted).length;

  List<AirdropEligibilityItem> get eligibilityChecklist =>
      <AirdropEligibilityItem>[
        AirdropEligibilityItem(
          id: 'elig_wallet',
          title: 'Bind BNB Smart Chain (BEP-20) Wallet',
          subtitle: boundWalletAddress == null
              ? 'Required to receive your 1B airdrop tokens at TGE'
              : 'Connected: ${boundWalletAddress!.substring(0, 8)}...${boundWalletAddress!.substring(boundWalletAddress!.length - 4)}',
          multiplierBonus: 'Required',
          isMet: boundWalletAddress != null,
          targetTabIndex: 4,
        ),
        AirdropEligibilityItem(
          id: 'elig_ads',
          title: 'Watch at least 3 Rewarded Ads',
          subtitle: '$totalAdsWatched / 3 verified ad sessions completed',
          multiplierBonus: '+0.25x Boost',
          isMet: totalAdsWatched >= 3,
          targetTabIndex: 2,
        ),
        AirdropEligibilityItem(
          id: 'elig_offers',
          title: 'Complete 2 Ecosystem Tasks',
          subtitle: '$completedOffersCount / 2 tasks verified',
          multiplierBonus: '+0.25x Boost',
          isMet: completedOffersCount >= 2,
          targetTabIndex: 2,
        ),
        AirdropEligibilityItem(
          id: 'elig_refer',
          title: 'Invite at least 1 Active Friend',
          subtitle: '${referrals.length} / 1 pioneer invited',
          multiplierBonus: '+0.50x Boost',
          isMet: referrals.isNotEmpty,
          targetTabIndex: 3,
        ),
      ];

  double get airdropMultiplier {
    var mult = 1.0;
    if (totalAdsWatched >= 3) mult += 0.25;
    if (completedOffersCount >= 2) mult += 0.25;
    if (referrals.isNotEmpty) mult += 0.50;
    if (referrals.length >= 10) mult += 0.50;
    return mult;
  }

  String get pioneerTier {
    if (airdropMultiplier >= 2.0) return 'Diamond Pioneer';
    if (airdropMultiplier >= 1.5) return 'Gold Pioneer';
    if (airdropMultiplier >= 1.25) return 'Silver Pioneer';
    return 'Bronze Pioneer';
  }

  double get projectedAirdropShare => balanceVtx * airdropMultiplier;

  bool get isEligibleForAirdrop =>
      boundWalletAddress != null && totalAdsWatched >= 3;

  UserCryptoState copyWith({
    bool? isRegistered,
    String? userId,
    String? displayName,
    String? email,
    double? balanceVtx,
    double? adEarnedVtx,
    double? referralEarnedVtx,
    double? miningEarnedVtx,
    double? offerEarnedVtx,
    int? totalAdsWatched,
    int? adsWatchedToday,
    int? tapsToday,
    int? streakDay,
    bool? streakClaimedToday,
    bool? miningActive,
    DateTime? miningSessionEnd,
    bool clearMiningSessionEnd = false,
    DateTime? lastMiningSync,
    bool clearLastMiningSync = false,
    DateTime? boost2xUntil,
    bool clearBoost2xUntil = false,
    String? boundWalletAddress,
    String? boundWalletProvider,
    String? referralCode,
    String? appliedSponsorCode,
    double? globalAirdropDistributed,
    bool? airdropRegistered,
    bool? notificationsEnabled,
    bool? miningAlertsEnabled,
    bool? hapticsEnabled,
    bool? biometricLockEnabled,
    List<EarnOffer>? offers,
    List<ReferralMember>? referrals,
    List<WalletTransaction>? transactions,
  }) {
    return UserCryptoState(
      isRegistered: isRegistered ?? this.isRegistered,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      balanceVtx: balanceVtx ?? this.balanceVtx,
      adEarnedVtx: adEarnedVtx ?? this.adEarnedVtx,
      referralEarnedVtx: referralEarnedVtx ?? this.referralEarnedVtx,
      miningEarnedVtx: miningEarnedVtx ?? this.miningEarnedVtx,
      offerEarnedVtx: offerEarnedVtx ?? this.offerEarnedVtx,
      totalAdsWatched: totalAdsWatched ?? this.totalAdsWatched,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      tapsToday: tapsToday ?? this.tapsToday,
      streakDay: streakDay ?? this.streakDay,
      streakClaimedToday: streakClaimedToday ?? this.streakClaimedToday,
      miningActive: miningActive ?? this.miningActive,
      miningSessionEnd: clearMiningSessionEnd
          ? null
          : (miningSessionEnd ?? this.miningSessionEnd),
      lastMiningSync:
          clearLastMiningSync ? null : (lastMiningSync ?? this.lastMiningSync),
      boost2xUntil:
          clearBoost2xUntil ? null : (boost2xUntil ?? this.boost2xUntil),
      boundWalletAddress: boundWalletAddress ?? this.boundWalletAddress,
      boundWalletProvider: boundWalletProvider ?? this.boundWalletProvider,
      referralCode: referralCode ?? this.referralCode,
      appliedSponsorCode: appliedSponsorCode ?? this.appliedSponsorCode,
      globalAirdropDistributed:
          globalAirdropDistributed ?? this.globalAirdropDistributed,
      airdropRegistered: airdropRegistered ?? this.airdropRegistered,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      miningAlertsEnabled: miningAlertsEnabled ?? this.miningAlertsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      offers: offers ?? this.offers,
      referrals: referrals ?? this.referrals,
      transactions: transactions ?? this.transactions,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'isRegistered': isRegistered,
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'balanceVtx': balanceVtx,
        'adEarnedVtx': adEarnedVtx,
        'referralEarnedVtx': referralEarnedVtx,
        'miningEarnedVtx': miningEarnedVtx,
        'offerEarnedVtx': offerEarnedVtx,
        'totalAdsWatched': totalAdsWatched,
        'adsWatchedToday': adsWatchedToday,
        'tapsToday': tapsToday,
        'streakDay': streakDay,
        'streakClaimedToday': streakClaimedToday,
        'miningActive': miningActive,
        'miningSessionEnd': miningSessionEnd?.toIso8601String(),
        'lastMiningSync': lastMiningSync?.toIso8601String(),
        'boost2xUntil': boost2xUntil?.toIso8601String(),
        'boundWalletAddress': boundWalletAddress,
        'boundWalletProvider': boundWalletProvider,
        'referralCode': referralCode,
        'appliedSponsorCode': appliedSponsorCode,
        'globalAirdropDistributed': globalAirdropDistributed,
        'airdropRegistered': airdropRegistered,
        'notificationsEnabled': notificationsEnabled,
        'miningAlertsEnabled': miningAlertsEnabled,
        'hapticsEnabled': hapticsEnabled,
        'biometricLockEnabled': biometricLockEnabled,
        'offers': offers.map((o) => o.toJson()).toList(),
        'referrals': referrals.map((r) => r.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory UserCryptoState.fromJson(Map<String, dynamic> json) {
    final offerList = (json['offers'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => EarnOffer.fromJson(e as Map<String, dynamic>))
        .toList();
    final refList = (json['referrals'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => ReferralMember.fromJson(e as Map<String, dynamic>))
        .toList();
    final txList = (json['transactions'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserCryptoState(
      isRegistered: json['isRegistered'] as bool? ?? false,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      balanceVtx: (json['balanceVtx'] as num).toDouble(),
      adEarnedVtx: (json['adEarnedVtx'] as num).toDouble(),
      referralEarnedVtx: (json['referralEarnedVtx'] as num).toDouble(),
      miningEarnedVtx: (json['miningEarnedVtx'] as num).toDouble(),
      offerEarnedVtx: (json['offerEarnedVtx'] as num).toDouble(),
      totalAdsWatched: (json['totalAdsWatched'] as num).toInt(),
      adsWatchedToday: (json['adsWatchedToday'] as num).toInt(),
      tapsToday: (json['tapsToday'] as num).toInt(),
      streakDay: (json['streakDay'] as num).toInt(),
      streakClaimedToday: json['streakClaimedToday'] as bool? ?? false,
      miningActive: json['miningActive'] as bool? ?? false,
      miningSessionEnd: json['miningSessionEnd'] != null
          ? DateTime.parse(json['miningSessionEnd'] as String)
          : null,
      lastMiningSync: json['lastMiningSync'] != null
          ? DateTime.parse(json['lastMiningSync'] as String)
          : null,
      boost2xUntil: json['boost2xUntil'] != null
          ? DateTime.parse(json['boost2xUntil'] as String)
          : null,
      boundWalletAddress: json['boundWalletAddress'] as String?,
      boundWalletProvider: json['boundWalletProvider'] as String?,
      referralCode: json['referralCode'] as String,
      appliedSponsorCode: json['appliedSponsorCode'] as String?,
      globalAirdropDistributed:
          (json['globalAirdropDistributed'] as num).toDouble(),
      airdropRegistered: json['airdropRegistered'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      miningAlertsEnabled: json['miningAlertsEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      biometricLockEnabled: json['biometricLockEnabled'] as bool? ?? false,
      offers: offerList,
      referrals: refList,
      transactions: txList,
    );
  }
}
