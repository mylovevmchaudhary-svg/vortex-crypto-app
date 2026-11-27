import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/crypto_models.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'refer_view_model.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({
    super.key,
    required this.viewModel,
  });

  final ReferViewModel viewModel;

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  final TextEditingController _sponsorController = TextEditingController();

  @override
  void dispose() {
    _sponsorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInviteHeroCard(context, state),
              const SizedBox(height: 16),
              _buildCommissionCard(context),
              const SizedBox(height: 16),
              _buildMilestoneCard(context, state.referrals.length),
              const SizedBox(height: 16),
              if (state.appliedSponsorCode == null) ...<Widget>[
                _buildApplySponsorCard(context),
                const SizedBox(height: 16),
              ],
              _buildTeamListSection(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInviteHeroCard(BuildContext context, UserCryptoState state) {
    final textScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
    final stackControls = textScale > 1.3;

    final codeInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'YOUR INVITE CODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          state.referralCode,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.goldBright,
          ),
        ),
      ],
    );

    final copyCodeButton = CyberOutlineButton(
      label: 'Copy Code',
      icon: Icons.copy,
      height: 48,
      accentColor: AppColors.goldBright,
      semanticLabel: 'Copy invite code ${state.referralCode}',
      onPressed: () => _copyText(
        context,
        state.referralCode,
        'Referral code ${state.referralCode} copied!',
      ),
    );

    final copyLinkButton = GoldGradientButton(
      label: 'Copy Invite Link',
      icon: Icons.share,
      onPressed: () => _copyText(
        context,
        widget.viewModel.inviteLink,
        'Invite link copied! Share on Telegram or WhatsApp.',
      ),
    );

    final testInviteButton = CyberOutlineButton(
      label: 'Test Invite',
      icon: Icons.person_add_alt_1,
      height: 52,
      accentColor: AppColors.cyan,
      semanticLabel: 'Simulate friend joining with invite code',
      onPressed: () => _showSimulateInviteDialog(context),
    );

    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.cyan.withValues(alpha: 0.45),
      glowColor: AppColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const StatusPill(
            label: '2-TIER REFERRAL REWARDS',
            color: AppColors.cyan,
            icon: Icons.group_add,
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              'Invite Friends & Earn +${TokenConfig.instantReferralBonus.toInt()} ${TokenConfig.coinSymbol}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plus ${TokenConfig.tier1ReferralPercent.toInt()}% lifetime boost from Tier 1 miners and ${TokenConfig.tier2ReferralPercent.toInt()}% from Tier 2.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderHighlight),
            ),
            child: stackControls
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      codeInfo,
                      const SizedBox(height: 10),
                      copyCodeButton,
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(child: codeInfo),
                      const SizedBox(width: 8),
                      copyCodeButton,
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          if (stackControls) ...<Widget>[
            copyLinkButton,
            const SizedBox(height: 10),
            testInviteButton,
          ] else
            Row(
              children: <Widget>[
                Expanded(child: copyLinkButton),
                const SizedBox(width: 10),
                testInviteButton,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(BuildContext context) {
    return GlassCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _TierBox(
                tier: 'TIER 1 (Direct)',
                percent: '${TokenConfig.tier1ReferralPercent.toInt()}%',
                subtitle:
                    '+${TokenConfig.instantReferralBonus.toInt()} ${TokenConfig.coinSymbol} instant',
                color: AppColors.goldBright,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TierBox(
                tier: 'TIER 2 (Team)',
                percent: '${TokenConfig.tier2ReferralPercent.toInt()}%',
                subtitle: 'Friends of friends',
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, int inviteCount) {
    final milestones = <(int, String, Color)>[
      (3, '+500 ${TokenConfig.coinSymbol}', AppColors.cyan),
      (10, '+2,500 ${TokenConfig.coinSymbol}', AppColors.goldBright),
      (25, '2.0x Airdrop', AppColors.violetBright),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Semantics(
                header: true,
                child: const Text(
                  'Airdrop Referral Milestones',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusPill(
                label: '$inviteCount INVITED',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: milestones.map((item) {
                final reached = inviteCount >= item.$1;
                return Expanded(
                  child: MergeSemantics(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: reached
                            ? item.$3.withValues(alpha: 0.14)
                            : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: reached ? item.$3 : AppColors.borderSubtle,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            reached ? Icons.verified : Icons.flag_outlined,
                            color: reached ? item.$3 : AppColors.textSecondary,
                            size: 20,
                            semanticLabel: reached ? 'Unlocked' : 'Locked',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.$1} Friends',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: item.$3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplySponsorCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: const Text(
              'Have a Sponsor Invite Code?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Link a friend\'s code to receive +100 ${TokenConfig.coinSymbol} welcome bonus.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _sponsorController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'e.g. VTX-10203',
                    labelText: 'Sponsor Invite Code',
                  ),
                  onSubmitted: (_) async {
                    final res = await widget.viewModel
                        .applySponsorCode(_sponsorController.text);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              CyberOutlineButton(
                label: 'Apply',
                height: 48,
                accentColor: AppColors.goldBright,
                semanticLabel: 'Apply sponsor invite code',
                onPressed: () async {
                  final res = await widget.viewModel
                      .applySponsorCode(_sponsorController.text);
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
    );
  }

  Widget _buildTeamListSection(BuildContext context, UserCryptoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Your Mining Team (${state.referrals.length})',
          subtitle:
              '${widget.viewModel.activeMinersCount} active • +${AppFormatters.formatTokens(state.referralEarnedVtx, decimals: 0)} ${TokenConfig.coinSymbol} earned',
        ),
        const SizedBox(height: 12),
        if (state.referrals.isEmpty)
          const GlassCard(
            child: Text(
              'No referrals yet. Share your code above to start earning 15% team rewards!',
            ),
          )
        else
          ...state.referrals.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MergeSemantics(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.cyan.withValues(alpha: 0.16),
                          child: Text(
                            member.displayName.isEmpty
                                ? 'P'
                                : member.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w800,
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
                              member.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Tier ${member.tier} • Joined ${AppFormatters.formatRelativeTime(member.joinedAt)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '+${member.contributedVtx.toInt()} ${TokenConfig.coinSymbol}',
                            style: const TextStyle(
                              color: AppColors.goldBright,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          StatusPill(
                            label: member.isActiveMiner ? 'MINING' : 'IDLE',
                            color: member.isActiveMiner
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _copyText(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showSimulateInviteDialog(BuildContext context) async {
    final nameController = TextEditingController(text: 'Rohan Sharma');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Simulate New Team Invite'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
          decoration: const InputDecoration(
            labelText: 'Friend Display Name',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Add Friend'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final res =
          await widget.viewModel.simulateFriendJoin(nameController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
    nameController.dispose();
  }
}

class _TierBox extends StatelessWidget {
  const _TierBox({
    required this.tier,
    required this.percent,
    required this.subtitle,
    required this.color,
  });

  final String tier;
  final String percent;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tier,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percent,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
