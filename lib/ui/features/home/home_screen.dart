import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/ads_service.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildBalanceHeroHeader(context, state.balanceVtx),
              const SizedBox(height: 16),
              _buildQuickActionCircleBar(context),
              const SizedBox(height: 18),
              _buildMiningCoreCard(context, pending),
              const SizedBox(height: 14),
              _buildAdBoostBanner(context),
              const SizedBox(height: 14),
              _buildEarningsBreakdownCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceHeroHeader(BuildContext context, double balanceVtx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            'TOTAL ${TokenConfig.coinSymbol} BALANCE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                AppFormatters.formatTokens(balanceVtx, decimals: 2),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 38,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              const Text(
                TokenConfig.coinSymbol,
                style: TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            button: true,
            label: 'View 1B Coin Airdrop details',
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: InkWell(
                onTap: () => onNavigateTab(1),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.rocket_launch,
                        size: 14,
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Pre-Launch • 1B ${TokenConfig.coinSymbol} Airdrop Pool',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.cyan,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCircleBar(BuildContext context) {
    final actions = <_CircleActionData>[
      _CircleActionData(
        label: 'Watch Ad',
        icon: Icons.play_arrow_rounded,
        color: AppColors.violetBright,
        onTap: () => _watchAd(context, AdPlacement.watchAndEarn),
      ),
      _CircleActionData(
        label: 'Airdrop',
        icon: Icons.rocket_launch_outlined,
        color: AppColors.cyan,
        onTap: () => onNavigateTab(1),
      ),
      _CircleActionData(
        label: 'Offers',
        icon: Icons.card_giftcard,
        color: AppColors.goldBright,
        onTap: () => onNavigateTab(2),
      ),
      _CircleActionData(
        label: 'Invite',
        icon: Icons.group_add_outlined,
        color: AppColors.success,
        onTap: () => onNavigateTab(3),
      ),
    ];

    return Row(
      children: actions
          .map(
            (item) => Expanded(
              child: Semantics(
                button: true,
                label: item.label,
                excludeSemantics: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.color.withValues(alpha: 0.14),
                              border: Border.all(
                                color: item.color.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Icon(item.icon, color: item.color, size: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMiningCoreCard(BuildContext context, double pending) {
    final state = viewModel.state;
    final miningActive = state.miningActive;
    final isBoosted = viewModel.isBoostActive;
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final orbSize = 178.0 * textScale.clamp(1.0, 1.55);
    final innerSize = 150.0 * textScale.clamp(1.0, 1.55);
    final remainingEnergy =
        (TokenConfig.dailyTapLimit - state.tapsToday).clamp(0, TokenConfig.dailyTapLimit);

    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: miningActive
          ? AppColors.cyan.withValues(alpha: 0.45)
          : AppColors.borderSubtle,
      glowColor: miningActive ? AppColors.cyan : AppColors.gold,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: const Text(
                        'Cloud Mining Node',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+${viewModel.currentHourlyRate.toStringAsFixed(1)} ${TokenConfig.coinSymbol}/hr',
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
                      '2X ${AppFormatters.formatCountdown(viewModel.boostRemaining)}',
                  color: AppColors.goldBright,
                  icon: Icons.bolt,
                )
              else
                StatusPill(
                  label: miningActive ? 'ACTIVE' : 'READY',
                  color: miningActive ? AppColors.success : AppColors.cyan,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Semantics(
            button: true,
            label:
                'Tap coin core to earn 1 ${TokenConfig.coinSymbol}. $remainingEnergy of ${TokenConfig.dailyTapLimit} energy remaining.',
            excludeSemantics: true,
            child: InkWell(
              onTap: () async {
                if (state.hapticsEnabled) {
                  await HapticFeedback.lightImpact();
                }
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
                duration: const Duration(milliseconds: 110),
                scale: viewModel.tapPulseTick.isOdd ? 0.95 : 1.0,
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
                          strokeWidth: 7,
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
                        padding: const EdgeInsets.all(10),
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
                            const VortexCoinEmblem(size: 50),
                            const SizedBox(height: 8),
                            Text(
                              miningActive
                                  ? '+${pending.toStringAsFixed(4)}'
                                  : 'TAP +1 ${TokenConfig.coinSymbol}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.goldBright,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                fontFeatures: <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              '$remainingEnergy/${TokenConfig.dailyTapLimit} Energy',
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
          Text(
            miningActive
                ? 'Session ends in ${AppFormatters.formatCountdown(viewModel.miningRemaining)} • Tap coin for instant ${TokenConfig.coinSymbol}'
                : 'Tap the coin core for instant ${TokenConfig.coinSymbol} or start 24h passive mining',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          GoldGradientButton(
            label: miningActive
                ? 'Harvest (+${pending.toStringAsFixed(2)} ${TokenConfig.coinSymbol})'
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

  Widget _buildAdBoostBanner(BuildContext context) {
    final state = viewModel.state;
    return GlassCard(
      gradient: LinearGradient(
        colors: <Color>[
          AppColors.violet.withValues(alpha: 0.2),
          AppColors.surfaceCard,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.violet.withValues(alpha: 0.4),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.violetGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.ondemand_video,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '2x Speed Ad Boost (+25 ${TokenConfig.coinSymbol})',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.adsWatchedToday}/${TokenConfig.dailyAdWatchLimit} ads watched today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CyberOutlineButton(
            label: viewModel.isLoadingAd ? 'Loading...' : 'Boost',
            accentColor: AppColors.violetBright,
            icon: Icons.bolt,
            semanticLabel: 'Watch rewarded ad for 2x mining speed boost',
            onPressed: viewModel.isLoadingAd
                ? null
                : () => _watchAd(context, AdPlacement.miningBoost2x),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdownCard(BuildContext context) {
    final state = viewModel.state;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: const Text(
              'Earnings Summary',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
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
                label: 'Ads',
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

  Future<void> _watchAd(BuildContext context, AdPlacement placement) async {
    final outcome = await viewModel.watchAd(placement);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(outcome.message)),
    );
  }
}

class _CircleActionData {
  const _CircleActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
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
