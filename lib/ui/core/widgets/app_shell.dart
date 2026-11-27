import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/crypto_repository.dart';
import '../../../domain/models/crypto_models.dart';
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

/// Mobile-first Web3 navigation shell supporting all 6 core pages:
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
                    center: Alignment(0.0, -0.9),
                    radius: 1.25,
                    colors: <Color>[
                      Color(0xFF131F38),
                      AppColors.bgPrimary,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: isWide
                      ? _buildWideBody(context, state)
                      : _buildMobileBody(context, state),
                ),
              ),
              bottomNavigationBar: isWide ? null : _buildMobileBottomBar(context),
            );
          },
        );
      },
    );
  }

  Widget _buildTopHeader(BuildContext context, UserCryptoState state) {
    final balanceText =
        '${AppFormatters.formatTokens(state.balanceVtx, decimals: 2)} ${TokenConfig.coinSymbol}';
    final textScale = MediaQuery.textScalerOf(context).scale(13.0) / 13.0;
    final stackHeader = textScale > 1.35;
    final initial = state.displayName.trim().isEmpty
        ? 'V'
        : state.displayName.trim()[0].toUpperCase();

    final brandBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: 'Open Profile',
          excludeSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: InkWell(
              onTap: () => onSelectTab(5),
              customBorder: const CircleBorder(),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xFF1A1100),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  const Text(
                    TokenConfig.coinName,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      TokenConfig.networkShort,
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                state.displayName.isEmpty
                    ? TokenConfig.projectTagline
                    : 'Hi, ${state.displayName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final balanceChip = Semantics(
      button: true,
      label: 'Open Wallet, balance $balanceText',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(
          child: InkWell(
            onTap: () => onSelectTab(4),
            focusColor: AppColors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const VortexCoinEmblem(size: 18, showGlow: false),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      balanceText,
                      style: const TextStyle(
                        color: AppColors.goldBright,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return FocusTraversalGroup(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 14, 4),
        child: stackHeader
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  brandBlock,
                  Align(
                    alignment: Alignment.centerRight,
                    child: balanceChip,
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(child: brandBlock),
                  const SizedBox(width: 8),
                  balanceChip,
                ],
              ),
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context, UserCryptoState state) {
    return Column(
      children: <Widget>[
        _buildTopHeader(context, state),
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

  Widget _buildWideBody(BuildContext context, UserCryptoState state) {
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
                  _buildTopHeader(context, state),
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
    final textScale = MediaQuery.textScalerOf(context).scale(11.0) / 11.0;
    final useScrollableTabs = textScale > 1.35;

    final tabWidgets = List<Widget>.generate(destinations.length, (index) {
      final item = destinations[index];
      final isSelected = index == currentIndex;

      final tile = Semantics(
        button: true,
        selected: isSelected,
        label: '${item.label} tab',
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: useScrollableTabs ? 76 : 48,
            minHeight: 54,
          ),
          child: InkWell(
            onTap: () => onSelectTab(index),
            focusColor: AppColors.cyan.withValues(alpha: 0.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: isSelected ? 22 : 0,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: AppColors.goldBright,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.goldBright
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: -0.2,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.goldBright
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      return useScrollableTabs ? tile : Expanded(child: tile);
    });

    return FocusTraversalGroup(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFA090D16),
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: useScrollableTabs
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: tabWidgets),
                  )
                : Row(children: tabWidgets),
          ),
        ),
      ),
    );
  }
}
