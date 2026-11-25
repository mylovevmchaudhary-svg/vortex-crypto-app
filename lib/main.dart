import 'package:flutter/material.dart';

import 'core/config/token_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/crypto_repository.dart';
import 'data/services/ads_service.dart';
import 'data/services/storage_service.dart';
import 'ui/core/widgets/app_shell.dart';
import 'ui/core/widgets/vortex_widgets.dart';
import 'ui/features/airdrop/airdrop_screen.dart';
import 'ui/features/airdrop/airdrop_view_model.dart';
import 'ui/features/home/home_screen.dart';
import 'ui/features/home/home_view_model.dart';
import 'ui/features/offer/offer_screen.dart';
import 'ui/features/offer/offer_view_model.dart';
import 'ui/features/profile/profile_screen.dart';
import 'ui/features/profile/profile_view_model.dart';
import 'ui/features/refer/refer_screen.dart';
import 'ui/features/refer/refer_view_model.dart';
import 'ui/features/wallet/wallet_screen.dart';
import 'ui/features/wallet/wallet_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = CryptoRepository(
    storageService: SharedPreferencesStorageService(),
    adsService: SimulatedRewardedAdsService(),
  );
  await repository.initialize();

  runApp(VortexCryptoApp(repository: repository));
}

class VortexCryptoApp extends StatefulWidget {
  const VortexCryptoApp({
    super.key,
    required this.repository,
    this.initialTabIndex = 0,
  });

  final CryptoRepository repository;
  final int initialTabIndex;

  @override
  State<VortexCryptoApp> createState() => _VortexCryptoAppState();
}

class _VortexCryptoAppState extends State<VortexCryptoApp> {
  late int _currentTabIndex;
  late final HomeViewModel _homeVm;
  late final AirdropViewModel _airdropVm;
  late final OfferViewModel _offerVm;
  late final ReferViewModel _referVm;
  late final WalletViewModel _walletVm;
  late final ProfileViewModel _profileVm;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex.clamp(0, 5);
    _homeVm = HomeViewModel(repository: widget.repository);
    _airdropVm = AirdropViewModel(repository: widget.repository);
    _offerVm = OfferViewModel(repository: widget.repository);
    _referVm = ReferViewModel(repository: widget.repository);
    _walletVm = WalletViewModel(repository: widget.repository);
    _profileVm = ProfileViewModel(repository: widget.repository);
  }

  void _selectTab(int index) {
    if (index < 0 || index > 5 || index == _currentTabIndex) return;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void dispose() {
    _homeVm.dispose();
    _airdropVm.dispose();
    _offerVm.dispose();
    _referVm.dispose();
    _walletVm.dispose();
    _profileVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TokenConfig.coinName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildDarkTheme(),
      home: ListenableBuilder(
        listenable: widget.repository,
        builder: (context, _) {
          if (!widget.repository.isInitialized) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    VortexCoinEmblem(size: 72),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: AppColors.goldBright),
                  ],
                ),
              ),
            );
          }
          return AppShell(
            repository: widget.repository,
            currentIndex: _currentTabIndex,
            onSelectTab: _selectTab,
            pages: <Widget>[
              HomeScreen(viewModel: _homeVm, onNavigateTab: _selectTab),
              AirdropScreen(viewModel: _airdropVm, onNavigateTab: _selectTab),
              OfferScreen(viewModel: _offerVm),
              ReferScreen(viewModel: _referVm),
              WalletScreen(viewModel: _walletVm),
              ProfileScreen(viewModel: _profileVm),
            ],
          );
        },
      ),
    );
  }
}
