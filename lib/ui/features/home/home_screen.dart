import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/ads_service.dart';
import '../../core/widgets/ad_player_dialog.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.onNavigateTab,
  });

  final HomeViewModel viewModel;
  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        final pending = viewModel.pendingMining;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildPortfolioBanner(
                context,
                state.balanceVtx,
                state.estimatedUsdValue,
                state.globalPoolProgress,
              ),
              const SizedBox(height: 16),
              _buildMiningCoreCard(context, pending),
              const SizedBox(height: 16),
              _buildAdBoostSpotlight(context),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Boost your 1B Airdrop allocation every day',
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 18),
              _buildEarningsBreakdownCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioBanner(
    BuildContext context,
    double balanceVtx,
    double usdValue,
    double poolProgress,
  ) {
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.gold.withValues(alpha: 0.35),
      glowColor: AppColors.gold,
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
                label: 'GENESIS MINING LIVE',
                color: AppColors.cyan,
                icon: Icons.sensors,
              ),
              Semantics(
                button: true,
                label:
                    'View 1B Airdrop progress, ${(poolProgress * 100).toStringAsFixed(1)} percent mined',
                excludeSemantics: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: InkWell(
                    onTap: () => onNavigateTab(1),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${(poolProgress * 100).toStringAsFixed(1)}% of 1B Pool',
                            style: const TextStyle(
                              color: AppColors.goldBright,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.goldBright,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Total Earned Balance',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                AppFormatters.formatTokens(balanceVtx, decimals: 2),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const Text(
                TokenConfig.coinSymbol,
                style: TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Est. Launch Value: ~${AppFormatters.formatUsd(usdValue)} @ \$${TokenConfig.indicativeListingPriceUsd.toStringAsFixed(3)}',
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiningCoreCard(BuildContext context, double pending) {
    final state = viewModel.state;
    final miningActive = state.miningActive;
    final isBoosted = viewModel.isBoostActive;
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final orbSize = 176.0 * textScale.clamp(1.0, 1.55);
    final innerSize = 148.0 * textScale.clamp(1.0, 1.55);

    return GlassCard(
      borderColor: miningActive
          ? AppColors.cyan.withValues(alpha: 0.45)
          : AppColors.borderSubtle,
      glowColor: miningActive ? AppColors.cyan : null,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Semantics(
                      header: true,
                      child: Text(
                        'Cloud Mining Node',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rate: +${viewModel.currentHourlyRate.toStringAsFixed(1)} ${TokenConfig.coinSymbol}/hr',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isBoosted ? AppColors.goldBright : AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isBoosted)
                StatusPill(
                  label:
                      '2X BOOST ${AppFormatters.formatCountdown(viewModel.boostRemaining)}',
                  color: AppColors.goldBright,
                  icon: Icons.bolt,
                )
              else
                StatusPill(
                  label: miningActive ? 'MINING ON' : 'IDLE',
                  color:
                      miningActive ? AppColors.success : AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            button: true,
            label: miningActive
                ? 'Tap coin core to earn 1 ${TokenConfig.coinSymbol}. ${state.tapsToday} of ${TokenConfig.dailyTapLimit} daily taps used.'
                : 'Tap coin core to earn 1 ${TokenConfig.coinSymbol}. ${state.tapsToday} of ${TokenConfig.dailyTapLimit} daily taps used.',
            excludeSemantics: true,
            child: InkWell(
              onTap: () async {
                final res = await viewModel.tapOrb();
                if (!context.mounted) return;
                if (!res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message)),
                  );
                }
              },
              customBorder: const CircleBorder(),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: viewModel.tapPulseTick.isOdd ? 0.96 : 1.0,
                child: SizedBox(
                  width: orbSize,
                  height: orbSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: orbSize,
                        height: orbSize,
                        child: CircularProgressIndicator(
                          value: miningActive
                              ? viewModel.miningSessionProgress.clamp(0.05, 1.0)
                              : 0.0,
                          strokeWidth: 8,
                          semanticsLabel: '24 hour cloud mining progress',
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isBoosted ? AppColors.goldBright : AppColors.cyan,
                          ),
                        ),
                      ),
                      Container(
                        width: innerSize,
                        height: innerSize,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: <Color>[
                              Color(0xFF1F2B46),
                              Color(0xFF0C1220),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const VortexCoinEmblem(size: 48),
                            const SizedBox(height: 6),
                            Text(
                              miningActive
                                  ? '+${pending.toStringAsFixed(4)}'
                                  : 'TAP +1 ${TokenConfig.coinSymbol}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.goldBright,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Taps: ${state.tapsToday}/${TokenConfig.dailyTapLimit}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (miningActive)
            Text(
              'Session resets in ${AppFormatters.formatCountdown(viewModel.miningRemaining)} • Tap core anytime for +1 ${TokenConfig.coinSymbol}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Text(
              'Start your 24h cloud miner & tap the coin core for bonus ${TokenConfig.coinSymbol}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          GoldGradientButton(
            label: miningActive
                ? 'Harvest (+${pending.toStringAsFixed(2)})'
                : 'Start 24h Mining',
            icon: miningActive ? Icons.downloading : Icons.play_arrow,
            onPressed: () async {
              final res = miningActive
                  ? await viewModel.claimMining()
                  : await viewModel.startMining();
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

  Widget _buildAdBoostSpotlight(BuildContext context) {
    final state = viewModel.state;
    return GlassCard(
      gradient: LinearGradient(
        colors: <Color>[
          AppColors.violet.withValues(alpha: 0.22),
          AppColors.surfaceCard,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.violet.withValues(alpha: 0.45),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.violetGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.ondemand_video,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Watch Ad • 2x Speed + 25 VTX',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ads today: ${state.adsWatchedToday} of ${TokenConfig.dailyAdWatchLimit} • Unlocks +2h 2x mining rate',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CyberOutlineButton(
            label: 'Watch',
            accentColor: AppColors.violetBright,
            icon: Icons.bolt,
            semanticLabel:
                'Watch ad for 2x mining speed boost and 25 ${TokenConfig.coinSymbol}',
            onPressed: () => _launchAd(context, AdPlacement.miningBoost2x),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        title: 'Watch Ads',
        subtitle: '+50 ${TokenConfig.coinSymbol} / Ad',
        icon: Icons.smart_display,
        color: AppColors.goldBright,
        onTap: () => _launchAd(context, AdPlacement.watchAndEarn),
      ),
      _QuickActionData(
        title: '1B Airdrop',
        subtitle: 'Check Eligibility',
        icon: Icons.rocket_launch,
        color: AppColors.cyan,
        onTap: () => onNavigateTab(1),
      ),
      _QuickActionData(
        title: 'Daily Offers',
        subtitle: 'Streaks & Tasks',
        icon: Icons.card_giftcard,
        color: AppColors.violetBright,
        onTap: () => onNavigateTab(2),
      ),
      _QuickActionData(
        title: 'Refer & Earn',
        subtitle: '15% Team Bonus',
        icon: Icons.group_add,
        color: AppColors.success,
        onTap: () => onNavigateTab(3),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaledFont = MediaQuery.textScalerOf(context).scale(14.5);
        final singleColumn = constraints.maxWidth < 340 || scaledFont >= 22;

        if (singleColumn) {
          return Column(
            children: actions
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QuickActionCard(item: item),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _QuickActionCard(item: actions[0])),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickActionCard(item: actions[1])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _QuickActionCard(item: actions[2])),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickActionCard(item: actions[3])),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEarningsBreakdownCard(BuildContext context) {
    final state = viewModel.state;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Semantics(
            header: true,
            child: Text(
              'Your Earning Sources',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _BreakdownStat(
                label: 'Mining',
                value:
                    AppFormatters.formatTokens(state.miningEarnedVtx, decimals: 0),
                color: AppColors.cyan,
              ),
              _BreakdownStat(
                label: 'Watch Ads',
                value:
                    AppFormatters.formatTokens(state.adEarnedVtx, decimals: 0),
                color: AppColors.goldBright,
              ),
              _BreakdownStat(
                label: 'Offers',
                value:
                    AppFormatters.formatTokens(state.offerEarnedVtx, decimals: 0),
                color: AppColors.violetBright,
              ),
              _BreakdownStat(
                label: 'Referrals',
                value: AppFormatters.formatTokens(
                  state.referralEarnedVtx,
                  decimals: 0,
                ),
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchAd(BuildContext context, AdPlacement placement) async {
    final result = await showRewardedAdDialog(
      context: context,
      adsService: viewModel.repository.adsService,
      placement: placement,
    );
    if (result == null || !context.mounted) return;
    final outcome = await viewModel.claimAdReward(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(outcome.message)),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.item});

  final _QuickActionData item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      semanticLabel: '${item.title}, ${item.subtitle}',
      onTap: item.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _BreakdownStat extends StatelessWidget {
  const _BreakdownStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Column(
          children: <Widget>[
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
