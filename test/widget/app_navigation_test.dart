import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vortex_crypto_app/data/repositories/crypto_repository.dart';
import 'package:vortex_crypto_app/data/services/ads_service.dart';
import 'package:vortex_crypto_app/data/services/storage_service.dart';
import 'package:vortex_crypto_app/main.dart';

void main() {
  Future<CryptoRepository> createRegisteredRepo() async {
    final repo = CryptoRepository(
      storageService: InMemoryStorageService(),
      adsService: TestAdsService(),
    );
    await repo.initialize();
    await repo.registerAccount(
      displayName: 'Mukesh Chaudhary',
      email: 'mukesh@example.com',
    );
    return repo;
  }

  testWidgets('shows onboarding screen on fresh install and signs up cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = CryptoRepository(
      storageService: InMemoryStorageService(),
      adsService: TestAdsService(),
    );
    await repo.initialize();

    await tester.pumpWidget(VortexCryptoApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Create Your Account'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Mukesh Chaudhary');
    await tester.enterText(find.byType(TextField).at(1), 'mukesh@example.com');
    await tester.tap(find.text('Start Earning VTX'));
    await tester.pumpAndSettle();

    expect(repo.state.isRegistered, isTrue);
    expect(find.text('Cloud Mining Node'), findsOneWidget);
  });

  testWidgets('renders all 6 pages on mobile screen with a11y guidelines',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = await createRegisteredRepo();
    await tester.pumpWidget(VortexCryptoApp(repository: repo));
    await tester.pumpAndSettle();

    // Home
    expect(find.text('Cloud Mining Node'), findsOneWidget);
    expect(find.text('TAP +1 VTX'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    // Tap core to earn +1 VTX
    await tester.tap(find.text('TAP +1 VTX'));
    await tester.pumpAndSettle();
    expect(repo.state.balanceVtx, 1.0);

    // Airdrop
    await tester.tap(find.text('Airdrop').last);
    await tester.pumpAndSettle();
    expect(find.text('1,000,000,000 COIN AIRDROP'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    // Offer
    await tester.tap(find.text('Offer'));
    await tester.pumpAndSettle();
    expect(find.text('Rewarded Video Ad Center'), findsOneWidget);

    // Refer
    await tester.tap(find.text('Refer'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR INVITE CODE'), findsOneWidget);

    // Wallet
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Bind Receiving Wallet (BEP-20)'), findsOneWidget);

    // Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Anti-Bot & KYC Airdrop Readiness'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    handle.dispose();
  });

  testWidgets('renders cleanly at 2.0x text scale across all 6 tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = await createRegisteredRepo();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: VortexCryptoApp(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    for (final tab in const <String>[
      'Airdrop',
      'Offer',
      'Refer',
      'Wallet',
      'Profile',
      'Home',
    ]) {
      final target = find.text(tab).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('switches to NavigationRail on wide tablet viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = await createRegisteredRepo();
    await tester.pumpWidget(VortexCryptoApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
