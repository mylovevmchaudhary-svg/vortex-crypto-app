import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/crypto_models.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'airdrop_view_model.dart';

class AirdropScreen extends StatelessWidget {
  const AirdropScreen({
    super.key,
    required this.viewModel,
    required this.onNavigateTab,
  });

  final AirdropViewModel viewModel;
  final ValueChanged<int> onNavigateTab;

  static const List<TokenomicsSlice> _tokenomics = <TokenomicsSlice>[
    TokenomicsSlice(
      label: '1B Community Airdrop Pool',
      percent: 50,
      amountLabel: '1,000,000,000 ${TokenConfig.coinSymbol}',
      color: AppColors.goldBright,
    ),
    TokenomicsSlice(
      label: 'PancakeSwap Liquidity & Launch',
      percent: 20,
      amountLabel: '400,000,000 ${TokenConfig.coinSymbol}',
      color: AppColors.cyan,
    ),
    TokenomicsSlice(
      label: 'Watch Ads & Ecosystem Rewards',
      percent: 15,
      amountLabel: '300,000,000 ${TokenConfig.coinSymbol}',
      color: AppColors.violetBright,
    ),
    TokenomicsSlice(
      label: 'Staking & Marketing Growth',
      percent: 10,
      amountLabel: '200,000,000 ${TokenConfig.coinSymbol}',
      color: AppColors.success,
    ),
    TokenomicsSlice(
      label: 'Core Team (12m Locked)',
      percent: 5,
      amountLabel: '100,000,000 ${TokenConfig.coinSymbol}',
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        final remainingPool =
            (TokenConfig.airdropPoolTotal - state.globalAirdropDistributed)
                .clamp(0.0, TokenConfig.airdropPoolTotal);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildPoolHeroCard(context, state, remainingPool),
              const SizedBox(height: 16),
              _buildEligibilitySection(context, state),
              const SizedBox(height: 18),
              const SectionHeader(
                title: '1B Airdrop & Launch Roadmap',
                subtitle: 'From community earning to BNB Smart Chain TGE',
              ),
              const SizedBox(height: 12),
              _buildRoadmapCard(context),
              const SizedBox(height: 18),
              _buildTokenomicsCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPoolHeroCard(
    BuildContext context,
    UserCryptoState state,
    double remainingPool,
  ) {
    final pct = (state.globalPoolProgress * 100).toStringAsFixed(2);
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.gold.withValues(alpha: 0.45),
      glowColor: AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              const StatusPill(
                label: '1,000,000,000 COIN AIRDROP',
                color: AppColors.goldBright,
                icon: Icons.rocket_launch,
              ),
              StatusPill(
                label: state.pioneerTier.toUpperCase(),
                color: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Your Projected Airdrop Claim',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.formatTokens(state.projectedAirdropShare, decimals: 0)} ${TokenConfig.coinSymbol}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.goldBright,
                              ),
                    ),
                    Text(
                      'Multiplier: ${state.airdropMultiplier.toStringAsFixed(2)}x on ${AppFormatters.formatTokens(state.balanceVtx, decimals: 0)} mined',
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const VortexCoinEmblem(size: 58),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Pool Mined: ${AppFormatters.formatCompact(state.globalAirdropDistributed)} / 1.00B',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.globalPoolProgress,
              minHeight: 10,
              semanticsLabel: '1 Billion coin airdrop pool progress',
              semanticsValue: '$pct percent distributed',
              backgroundColor: AppColors.bgPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppFormatters.formatTokens(remainingPool, decimals: 0)} ${TokenConfig.coinSymbol} remaining before Snapshot & Exchange Launch',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          GoldGradientButton(
            label: state.airdropRegistered
                ? 'Snapshot Spot Verified (${state.pioneerTier})'
                : 'Lock 1B Airdrop Spot (+250 ${TokenConfig.coinSymbol})',
            icon: state.airdropRegistered ? Icons.verified : Icons.lock_clock,
            onPressed: state.airdropRegistered
                ? null
                : () async {
                    final res = await viewModel.registerSnapshotSpot();
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

  Widget _buildEligibilitySection(
    BuildContext context,
    UserCryptoState state,
  ) {
    final items = state.eligibilityChecklist;
    final metCount = items.where((item) => item.isMet).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: 'Airdrop Eligibility & Multipliers',
          subtitle: 'Complete tasks to boost your 1B claim share',
          trailing: StatusPill(
            label: '$metCount/${items.length} READY',
            color:
                metCount == items.length ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              borderColor: item.isMet
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MergeSemantics(
                      child: Row(
                        children: <Widget>[
                          ExcludeSemantics(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (item.isMet
                                        ? AppColors.success
                                        : AppColors.gold)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.isMet
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: item.isMet
                                    ? AppColors.success
                                    : AppColors.gold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.isMet)
                    StatusPill(
                      label: item.multiplierBonus,
                      color: AppColors.success,
                    )
                  else
                    CyberOutlineButton(
                      label: 'Go',
                      height: 48,
                      accentColor: AppColors.goldBright,
                      semanticLabel: 'Go to ${item.title}',
                      onPressed: () => onNavigateTab(item.targetTabIndex),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapCard(BuildContext context) {
    final phases = viewModel.phases;
    return GlassCard(
      child: Column(
        children: List<Widget>.generate(phases.length, (index) {
          final phase = phases[index];
          final isActive = phase.status == RoadmapPhaseStatus.active;
          final isCompleted = phase.status == RoadmapPhaseStatus.completed;
          final isLast = index == phases.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? AppColors.cyan
                            : AppColors.surfaceElevated,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? AppColors.cyan
                              : AppColors.borderHighlight,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Color(0xFF001F1A),
                              )
                            : Text(
                                '${phase.phaseNumber}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isActive
                                      ? const Color(0xFF001F1A)
                                      : AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.borderSubtle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              phase.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            StatusPill(
                              label: phase.targetLabel,
                              color: isActive
                                  ? AppColors.cyan
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phase.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTokenomicsCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: const Text(
              'Real BEP-20 Tokenomics (2B Supply)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale =
                  MediaQuery.textScalerOf(context).scale(12.0) / 12.0;
              final stackVertically =
                  constraints.maxWidth < 340 || textScale > 1.3;

              final legend = Column(
                children: _tokenomics
                    .map(
                      (slice) => MergeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: <Widget>[
                              ExcludeSemantics(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: slice.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  slice.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${slice.percent.toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: slice.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );

              if (stackVertically) {
                return Column(
                  children: <Widget>[
                    const Center(
                      child: TokenomicsDonutChart(slices: _tokenomics, size: 132),
                    ),
                    const SizedBox(height: 16),
                    legend,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  const TokenomicsDonutChart(slices: _tokenomics, size: 132),
                  const SizedBox(width: 16),
                  Expanded(child: legend),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
