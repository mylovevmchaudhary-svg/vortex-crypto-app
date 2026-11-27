import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/models/crypto_models.dart';
import '../../core/widgets/vortex_widgets.dart';
import 'wallet_view_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
    required this.viewModel,
  });

  final WalletViewModel viewModel;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  String? _validationError;

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        final txs = widget.viewModel.filteredTransactions;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildWalletPortfolioCard(context, state),
              const SizedBox(height: 16),
              _buildBindBep20Card(context, state),
              const SizedBox(height: 16),
              _buildContractSpecCard(context),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Reward Ledger & Transactions',
                subtitle: 'Verified mining, ad, and referral credits',
              ),
              const SizedBox(height: 10),
              _buildTxFilterChips(),
              const SizedBox(height: 12),
              if (txs.isEmpty)
                const GlassCard(
                  child: Row(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No activity yet. Start mining or watch a rewarded ad to record your first verified transaction.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...txs.map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTxTile(context, tx),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletPortfolioCard(
    BuildContext context,
    UserCryptoState state,
  ) {
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.gold.withValues(alpha: 0.4),
      glowColor: AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              const StatusPill(
                label:
                    '${TokenConfig.networkName} (${TokenConfig.networkShort})',
                color: AppColors.goldBright,
                icon: Icons.hub,
              ),
              StatusPill(
                label: state.boundWalletAddress != null
                    ? 'WALLET READY'
                    : 'UNLINKED',
                color: state.boundWalletAddress != null
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Pre-Launch Token Vault',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppFormatters.formatTokens(state.balanceVtx, decimals: 2)} ${TokenConfig.coinSymbol}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Price & DEX liquidity open at PancakeSwap TGE Launch',
            style: TextStyle(
              color: AppColors.cyan,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'LOCKED FOR 1B AIRDROP',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.formatTokens(state.balanceVtx, decimals: 0)} ${TokenConfig.coinSymbol}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.borderSubtle,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ON-CHAIN CLAIM STATUS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Opens at Phase 3 TGE',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBindBep20Card(BuildContext context, UserCryptoState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: const Text(
              'Bind Receiving Wallet (BEP-20)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your BNB Smart Chain (BEP-20) address from MetaMask, Trust Wallet, or Binance Web3 Wallet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (state.boundWalletAddress != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const ExcludeSemantics(
                    child: Icon(Icons.verified, color: AppColors.success),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${state.boundWalletProvider ?? 'BEP-20'} Connected',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            AppFormatters.shortenAddress(
                              state.boundWalletAddress!,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy Wallet Address',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: state.boundWalletAddress!),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('BEP-20 address copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WalletViewModel.walletProviders.map((provider) {
              final selected = widget.viewModel.selectedProvider == provider;
              return ChoiceChip(
                label: Text(provider),
                selected: selected,
                onSelected: (_) => widget.viewModel.selectProvider(provider),
                selectedColor: AppColors.cyan.withValues(alpha: 0.18),
                backgroundColor: AppColors.bgSecondary,
                side: BorderSide(
                  color: selected ? AppColors.cyan : AppColors.borderControl,
                ),
                labelStyle: TextStyle(
                  color: selected ? AppColors.cyan : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            focusNode: _addressFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitWalletBind(context),
            decoration: InputDecoration(
              hintText: '0x...',
              labelText: 'BSC Wallet Address (0x...)',
              errorText: _validationError,
              suffixIcon: Semantics(
                button: true,
                label: 'Paste BEP-20 address from clipboard',
                excludeSemantics: true,
                child: TextButton(
                  onPressed: () async {
                    final clip = await Clipboard.getData(Clipboard.kTextPlain);
                    final text = clip?.text?.trim() ?? '';
                    if (text.isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Clipboard is empty. Copy your 0x... address from MetaMask or Trust Wallet.',
                          ),
                        ),
                      );
                      return;
                    }
                    _addressController.text = text;
                    setState(() => _validationError = null);
                  },
                  child: const Text('Paste'),
                ),
              ),
            ),
            onChanged: (_) {
              if (_validationError != null) {
                setState(() => _validationError = null);
              }
            },
          ),
          const SizedBox(height: 12),
          GoldGradientButton(
            label: state.boundWalletAddress == null
                ? 'Bind BEP-20 Wallet (+100 ${TokenConfig.coinSymbol})'
                : 'Update Connected Wallet',
            icon: Icons.account_balance_wallet,
            onPressed: () => _submitWalletBind(context),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWalletBind(BuildContext context) async {
    final error = AppValidators.validateBep20Address(_addressController.text);
    if (error != null) {
      setState(() => _validationError = error);
      _addressFocusNode.requestFocus();
      return;
    }
    final res = await widget.viewModel.bindBep20Address(_addressController.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
  }

  Widget _buildContractSpecCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: const Text(
                    'Smart Contract Specs (BSC)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final target = TokenConfig.isContractDeployed
                      ? '${TokenConfig.explorerBaseUrl}/token/${TokenConfig.tokenContractAddress}'
                      : TokenConfig.explorerBaseUrl;
                  final uri = Uri.tryParse(target);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 15),
                label: const Text('BscScan'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _SpecRow(
            label: 'Token Name & Ticker',
            value: '${TokenConfig.coinName} (${TokenConfig.coinSymbol})',
          ),
          const _SpecRow(
            label: 'Network & Chain ID',
            value: '${TokenConfig.networkName} (${TokenConfig.chainId})',
          ),
          _SpecRow(
            label: 'Max Supply / 1B Airdrop',
            value:
                '${AppFormatters.formatCompact(TokenConfig.totalSupply)} / ${AppFormatters.formatCompact(TokenConfig.airdropPoolTotal)}',
          ),
          _SpecRow(
            label: 'Contract Status',
            value: TokenConfig.isContractDeployed
                ? AppFormatters.shortenAddress(TokenConfig.tokenContractAddress)
                : 'Deploying at Phase 3 TGE',
          ),
        ],
      ),
    );
  }

  Widget _buildTxFilterChips() {
    final items = <(WalletTxFilter, String)>[
      (WalletTxFilter.all, 'All Activity'),
      (WalletTxFilter.mining, 'Mining'),
      (WalletTxFilter.ads, 'Watch Ads'),
      (WalletTxFilter.other, 'Offers & Refer'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((entry) {
          final isSelected = widget.viewModel.txFilter == entry.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.$2),
              selected: isSelected,
              onSelected: (_) => widget.viewModel.selectTxFilter(entry.$1),
              selectedColor: AppColors.gold.withValues(alpha: 0.2),
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

  Widget _buildTxTile(BuildContext context, WalletTransaction tx) {
    final (icon, color) = switch (tx.type) {
      TransactionType.mining ||
      TransactionType.tap =>
        (Icons.bolt, AppColors.cyan),
      TransactionType.adReward =>
        (Icons.ondemand_video, AppColors.violetBright),
      TransactionType.referral => (Icons.group_add, AppColors.success),
      TransactionType.dailyStreak ||
      TransactionType.offer ||
      TransactionType.airdropBonus =>
        (Icons.card_giftcard, AppColors.goldBright),
    };

    return MergeSemantics(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${tx.subtitle} • ${AppFormatters.formatRelativeTime(tx.timestamp)}',
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
                  '+${AppFormatters.formatTokens(tx.amount, decimals: tx.amount % 1 == 0 ? 0 : 2)}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const Text(
                  TokenConfig.coinSymbol,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
