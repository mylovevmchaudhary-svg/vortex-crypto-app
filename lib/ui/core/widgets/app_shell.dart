import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/crypto_repository.dart';
import 'vortex_widgets.dart';

class NavDestinationItem {
  const NavDestinationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Responsive Web3 navigation shell supporting all 6 core pages:
/// Home, Airdrop, Offer, Refer, Wallet, and Profile.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.repository,
    required this.currentIndex,
    required this.onSelectTab,
    required this.pages,
  });

  final CryptoRepository repository;
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final List<Widget> pages;

  static const double _wideLayoutBreakpoint = 680.0;

  static const List<NavDestinationItem> destinations = <NavDestinationItem>[
    NavDestinationItem(
      label: 'Home',
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt,
    ),
    NavDestinationItem(
      label: 'Airdrop',
      icon: Icons.rocket_launch_outlined,
      activeIcon: Icons.rocket_launch,
    ),
    NavDestinationItem(
      label: 'Offer',
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle_filled,
    ),
    NavDestinationItem(
      label: 'Refer',
      icon: Icons.group_add_outlined,
      activeIcon: Icons.group_add,
    ),
    NavDestinationItem(
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
    ),
    NavDestinationItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final state = repository.state;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > _wideLayoutBreakpoint;
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.85),
                    radius: 1.3,
                    colors: <Color>[
                      Color(0xFF131D33),
                      AppColors.bgPrimary,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: isWide
                      ? _buildWideBody(context, state.balanceVtx)
                      : _buildMobileBody(context, state.balanceVtx),
                ),
              ),
              bottomNavigationBar: isWide ? null : _buildMobileBottomBar(context),
            );
          },
        );
      },
    );
  }

  Widget _buildTopHeader(BuildContext context, double balanceVtx) {
    final balanceText =
        '${AppFormatters.formatTokens(balanceVtx, decimals: 1)} ${TokenConfig.coinSymbol}';
    return FocusTraversalGroup(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Row(
          children: <Widget>[
            const VortexCoinEmblem(size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const <Widget>[
                      Text(
                        TokenConfig.coinName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      StatusPill(
                        label: TokenConfig.networkShort,
                        color: AppColors.cyan,
                      ),
                    ],
                  ),
                  const Text(
                    '1B Coin Airdrop Pre-Launch',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Open Wallet, balance $balanceText',
              excludeSemantics: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: InkWell(
                    onTap: () => onSelectTab(4),
                    focusColor: AppColors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.monetization_on,
                            color: AppColors.goldBright,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            balanceText,
                            style: const TextStyle(
                              color: AppColors.goldBright,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context, double balanceVtx) {
    return Column(
      children: <Widget>[
        _buildTopHeader(context, balanceVtx),
        Expanded(
          child: FocusTraversalGroup(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideBody(BuildContext context, double balanceVtx) {
    return Row(
      children: <Widget>[
        FocusTraversalGroup(
          child: NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onSelectTab,
            backgroundColor: AppColors.bgSecondary,
            indicatorColor: AppColors.gold.withValues(alpha: 0.18),
            selectedIconTheme: const IconThemeData(color: AppColors.goldBright),
            unselectedIconTheme:
                const IconThemeData(color: AppColors.textSecondary),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.goldBright,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: VortexCoinEmblem(size: 40),
            ),
            destinations: destinations
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.borderSubtle),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                children: <Widget>[
                  _buildTopHeader(context, balanceVtx),
                  Expanded(
                    child: FocusTraversalGroup(
                      child: IndexedStack(
                        index: currentIndex,
                        children: pages,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    return FocusTraversalGroup(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xF50B0F1A),
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: List<Widget>.generate(destinations.length, (index) {
                final item = destinations[index];
                final isSelected = index == currentIndex;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${item.label} tab',
                    excludeSemantics: true,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: InkWell(
                        onTap: () => onSelectTab(index),
                        focusColor: AppColors.cyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 21,
                                color: isSelected
                                    ? AppColors.goldBright
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.goldBright
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
