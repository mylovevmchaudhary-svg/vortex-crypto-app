import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/crypto_repository.dart';
import '../../../data/services/ads_service.dart';
import '../../../domain/models/crypto_models.dart';
import '../../core/widgets/ad_player_dialog.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'offer_view_model.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({
    super.key,
    required this.viewModel,
  });

  final OfferViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        final offers = viewModel.filteredOffers;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildWatchAdsHub(context, state),
              const SizedBox(height: 18),
              _buildDailyStreakCard(context, state),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Offerwall & Verified Tasks',
                subtitle:
                    'Earn extra ${TokenConfig.coinSymbol} toward your 1B Airdrop tier',
              ),
              const SizedBox(height: 10),
              _buildFilterChips(),
              const SizedBox(height: 12),
              ...offers.map(
                (offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildOfferCard(context, offer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWatchAdsHub(BuildContext context, UserCryptoState state) {
    final remainingAds =
        (TokenConfig.dailyAdWatchLimit - state.adsWatchedToday)
            .clamp(0, TokenConfig.dailyAdWatchLimit);
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.violet.withValues(alpha: 0.45),
      glowColor: AppColors.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const StatusPill(
                label: 'WATCH ADS TO EARN',
                color: AppColors.violetBright,
                icon: Icons.ondemand_video,
              ),
              Text(
                '$remainingAds of ${TokenConfig.dailyAdWatchLimit} left today',
                style: const TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Semantics(
            header: true,
            child: Text(
              'Rewarded Video Ad Center',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Every verified ad view rewards you instantly and strengthens project DEX liquidity.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _AdOptionTile(
            title: 'Standard Video Ad',
            subtitle: 'Watch a short sponsor clip',
            rewardLabel:
                '+${TokenConfig.standardAdReward.toInt()} ${TokenConfig.coinSymbol}',
            icon: Icons.play_circle_fill,
            accent: AppColors.goldBright,
            onTap: () => _watchAd(context, AdPlacement.watchAndEarn),
          ),
          const SizedBox(height: 10),
          _AdOptionTile(
            title: '2x Mining Speed Boost Ad',
            subtitle: 'Doubles cloud mining rate for 2 hours',
            rewardLabel: '+25 ${TokenConfig.coinSymbol} & 2X',
            icon: Icons.bolt,
            accent: AppColors.cyan,
            onTap: () => _watchAd(context, AdPlacement.miningBoost2x),
          ),
          const SizedBox(height: 10),
          _AdOptionTile(
            title: 'Mystery Ad Crate',
            subtitle: 'Win 25 to 150 ${TokenConfig.coinSymbol} randomly',
            rewardLabel: 'UP TO +150 ${TokenConfig.coinSymbol}',
            icon: Icons.auto_awesome,
            accent: AppColors.violetBright,
            onTap: () => _watchAd(context, AdPlacement.mysteryCrate),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStreakCard(BuildContext context, UserCryptoState state) {
    const rewards = CryptoRepository.dailyStreakRewards;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    '7-Day Check-In Streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              StatusPill(
                label: 'DAY ${state.streakDay + 1} OF 7',
                color: AppColors.goldBright,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(rewards.length, (index) {
                final isPast = index < state.streakDay;
                final isCurrent = index == state.streakDay;
                final statusText = isPast
                    ? 'Claimed'
                    : isCurrent
                        ? 'Current day, +${rewards[index].toInt()} ${TokenConfig.coinSymbol}'
                        : 'Upcoming, +${rewards[index].toInt()} ${TokenConfig.coinSymbol}';
                return Semantics(
                  label: 'Day ${index + 1}: $statusText',
                  excludeSemantics: true,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 72,
                      minHeight: 78,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index == rewards.length - 1 ? 0 : 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.gold.withValues(alpha: 0.16)
                            : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.goldBright
                              : isPast
                                  ? AppColors.success.withValues(alpha: 0.5)
                                  : AppColors.borderSubtle,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            isCurrent ? 'TODAY' : 'Day ${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? AppColors.goldBright
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isPast)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 18,
                              semanticLabel: 'Claimed',
                            )
                          else
                            Text(
                              '+${rewards[index].toInt()}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? AppColors.goldBright
                                    : AppColors.textPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          GoldGradientButton(
            label: state.streakClaimedToday
                ? 'Today\'s Check-In Claimed'
                : 'Claim Day ${state.streakDay + 1} (+${rewards[state.streakDay].toInt()} ${TokenConfig.coinSymbol})',
            icon: state.streakClaimedToday
                ? Icons.check_circle
                : Icons.calendar_today,
            onPressed: state.streakClaimedToday
                ? null
                : () async {
                    final res = await viewModel.claimDailyStreak();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message)),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = <(OfferFilter, String)>[
      (OfferFilter.all, 'All Offers'),
      (OfferFilter.social, 'Social'),
      (OfferFilter.partner, 'Partners'),
      (OfferFilter.ads, 'Video Tasks'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((entry) {
          final isSelected = viewModel.selectedFilter == entry.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.$2),
              selected: isSelected,
              onSelected: (_) => viewModel.selectFilter(entry.$1),
              selectedColor: AppColors.gold.withValues(alpha: 0.22),
              backgroundColor: AppColors.surfaceCard,
              side: BorderSide(
                color: isSelected ? AppColors.gold : AppColors.borderControl,
              ),
              labelStyle: TextStyle(
                color:
                    isSelected ? AppColors.goldBright : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, EarnOffer offer) {
    return GlassCard(
      padding: const EdgeInsets.all(15),
      borderColor: offer.isCompleted
          ? AppColors.success.withValues(alpha: 0.35)
          : AppColors.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (offer.isCompleted ? AppColors.success : AppColors.gold)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                offer.isCompleted
                    ? Icons.verified
                    : offer.category == OfferCategory.social
                        ? Icons.campaign
                        : Icons.stars,
                color:
                    offer.isCompleted ? AppColors.success : AppColors.goldBright,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          StatusPill(
                            label: offer.badgeText,
                            color: AppColors.cyan,
                          ),
                          Text(
                            offer.durationLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        offer.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      '+${offer.reward.toInt()} ${TokenConfig.coinSymbol}',
                      style: const TextStyle(
                        color: AppColors.goldBright,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (offer.isCompleted)
                      const StatusPill(
                        label: 'CLAIMED',
                        color: AppColors.success,
                        icon: Icons.check,
                      )
                    else
                      CyberOutlineButton(
                        label: offer.actionLabel,
                        height: 48,
                        accentColor: AppColors.goldBright,
                        semanticLabel:
                            '${offer.actionLabel} for ${offer.title} (+${offer.reward.toInt()} ${TokenConfig.coinSymbol})',
                        onPressed: () async {
                          final res = await viewModel.completeOffer(offer.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res.message)),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAd(BuildContext context, AdPlacement placement) async {
    final result = await showRewardedAdDialog(
      context: context,
      adsService: viewModel.repository.adsService,
      placement: placement,
    );
    if (result == null || !context.mounted) return;
    final outcome = await viewModel.claimWatchedAd(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(outcome.message)),
    );
  }
}

class _AdOptionTile extends StatelessWidget {
  const _AdOptionTile({
    required this.title,
    required this.subtitle,
    required this.rewardLabel,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String rewardLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CyberOutlineButton(
            label: rewardLabel,
            height: 48,
            accentColor: accent,
            semanticLabel: 'Watch $title for $rewardLabel',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
