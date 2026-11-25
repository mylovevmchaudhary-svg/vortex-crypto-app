import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/crypto_models.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.viewModel,
  });

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildIdentityCard(context, state),
              const SizedBox(height: 16),
              _buildVerificationReadinessCard(context, state),
              const SizedBox(height: 16),
              _buildWhitepaperCard(context),
              const SizedBox(height: 16),
              _buildPreferencesCard(context, state),
              const SizedBox(height: 16),
              _buildDangerZoneCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdentityCard(BuildContext context, UserCryptoState state) {
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.gold.withValues(alpha: 0.35),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  state.displayName.isEmpty
                      ? 'V'
                      : state.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1100),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          state.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit Pioneer Name',
                      onPressed: () =>
                          _editDisplayName(context, state.displayName),
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.goldBright,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${state.userId} • ${state.email}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    StatusPill(
                      label: state.pioneerTier.toUpperCase(),
                      color: AppColors.goldBright,
                      icon: Icons.workspace_premium,
                    ),
                    StatusPill(
                      label: '${state.totalAdsWatched} ADS VERIFIED',
                      color: AppColors.cyan,
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

  Widget _buildVerificationReadinessCard(
    BuildContext context,
    UserCryptoState state,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Semantics(
            header: true,
            child: Text(
              'Anti-Bot & KYC Airdrop Readiness',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _CheckRow(
            label: 'Device Integrity & Anti-Sybil Check',
            value: 'Passed (98%)',
            passed: true,
          ),
          _CheckRow(
            label: 'Rewarded Ads Proof-of-Humanity',
            value: state.totalAdsWatched >= 3
                ? 'Verified (${state.totalAdsWatched} of 3)'
                : 'Watch ${3 - state.totalAdsWatched} more ads',
            passed: state.totalAdsWatched >= 3,
          ),
          _CheckRow(
            label: 'BNB Smart Chain Wallet Binding',
            value: state.boundWalletAddress != null
                ? AppFormatters.shortenAddress(state.boundWalletAddress!)
                : 'Pending',
            passed: state.boundWalletAddress != null,
          ),
        ],
      ),
    );
  }

  Widget _buildWhitepaperCard(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.violet.withValues(alpha: 0.4),
      semanticLabel:
          'Whitepaper and 1B Launch Architecture. Tap to read how Ad Revenue funds PancakeSwap liquidity and BEP-20 launch.',
      onTap: () => _showLaunchBlueprintSheet(context),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.violetGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Whitepaper & 1B Launch Architecture',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'How Ad Revenue funds PancakeSwap liquidity & BEP-20 launch',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const ExcludeSemantics(
            child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, UserCryptoState state) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Airdrop & Launch Notifications'),
            subtitle: const Text('Snapshot alerts & exchange listing news'),
            value: state.notificationsEnabled,
            thumbColor: _thumbColor(AppColors.goldBright),
            onChanged: viewModel.toggleNotifications,
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('24h Cloud Mining Reminder'),
            subtitle: const Text('Ping when mining cycle finishes'),
            value: state.miningAlertsEnabled,
            thumbColor: _thumbColor(AppColors.cyan),
            onChanged: viewModel.toggleMiningAlerts,
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Haptic Tap Feedback'),
            subtitle: const Text('Tactile pulse on coin core taps'),
            value: state.hapticsEnabled,
            thumbColor: _thumbColor(AppColors.goldBright),
            onChanged: viewModel.toggleHaptics,
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Wallet Security Lock'),
            subtitle: const Text('Require PIN / Biometrics before claim'),
            value: state.biometricLockEnabled,
            thumbColor: _thumbColor(AppColors.violetBright),
            onChanged: viewModel.toggleBiometricLock,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    return GlassCard(
      child: Row(
        children: <Widget>[
          const ExcludeSemantics(
            child: Icon(Icons.restart_alt, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Reset Demo Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Restore starter balance and test all user flows fresh',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Reset demo progress',
            excludeSemantics: true,
            child: TextButton(
              onPressed: () async {
                await viewModel.resetDemoData();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo account reset cleanly.')),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.warning),
              ),
            ),
          ),
        ],
      ),
    );
  }

  WidgetStateProperty<Color?> _thumbColor(Color activeColor) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return activeColor;
      }
      return null;
    });
  }

  Future<void> _editDisplayName(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Update Pioneer Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await viewModel.updateDisplayName(controller.text);
    }
    controller.dispose();
  }

  void _showLaunchBlueprintSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        '${TokenConfig.coinName} (${TokenConfig.coinSymbol}) Real Launch Model',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close Whitepaper',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _BlueprintPoint(
                step: '1',
                title: 'Watch-to-Earn Ad Revenue Engine',
                detail:
                    'Users earn VTX via AdMob Rewarded Video Ads + SSV callbacks. Ad revenue generates real USDT/BNB treasury to back token liquidity.',
              ),
              const _BlueprintPoint(
                step: '2',
                title: '1,000,000,000 Coin Airdrop (50% Supply)',
                detail:
                    'Before DEX launch, snapshot verified balances & bound BEP-20 addresses into a Merkle Tree for gas-efficient on-chain claiming.',
              ),
              const _BlueprintPoint(
                step: '3',
                title: 'BEP-20 Deployment & PancakeSwap Launch',
                detail:
                    'Deploy contracts/VortexToken.sol on BNB Smart Chain, lock PancakeSwap LP tokens, and open VortexMerkleAirdrop.sol for claims.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.passed,
  });

  final String label;
  final String value;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(
                passed ? Icons.check_circle : Icons.pending_outlined,
                size: 18,
                color: passed ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: passed ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueprintPoint extends StatelessWidget {
  const _BlueprintPoint({
    required this.step,
    required this.title,
    required this.detail,
  });

  final String step;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.goldBright,
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Color(0xFF1A1100),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
