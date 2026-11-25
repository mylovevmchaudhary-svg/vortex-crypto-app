import 'package:flutter/foundation.dart';

import '../../../data/repositories/crypto_repository.dart';
import '../../../domain/models/crypto_models.dart';

enum WalletTxFilter {
  all,
  mining,
  ads,
  other,
}

class WalletViewModel extends ChangeNotifier {
  WalletViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
  }

  final CryptoRepository _repository;
  String _selectedProvider = 'MetaMask';
  WalletTxFilter _txFilter = WalletTxFilter.all;

  static const List<String> walletProviders = <String>[
    'MetaMask',
    'Trust Wallet',
    'Binance Web3',
    'SafePal',
  ];

  UserCryptoState get state => _repository.state;
  String get selectedProvider => _selectedProvider;
  WalletTxFilter get txFilter => _txFilter;

  List<WalletTransaction> get filteredTransactions {
    final txs = state.transactions;
    return switch (_txFilter) {
      WalletTxFilter.all => txs,
      WalletTxFilter.mining => txs
          .where((t) =>
              t.type == TransactionType.mining || t.type == TransactionType.tap)
          .toList(),
      WalletTxFilter.ads =>
        txs.where((t) => t.type == TransactionType.adReward).toList(),
      WalletTxFilter.other => txs
          .where((t) =>
              t.type == TransactionType.offer ||
              t.type == TransactionType.dailyStreak ||
              t.type == TransactionType.referral ||
              t.type == TransactionType.airdropBonus)
          .toList(),
    };
  }

  void selectProvider(String provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void selectTxFilter(WalletTxFilter filter) {
    _txFilter = filter;
    notifyListeners();
  }

  Future<ActionResult> bindBep20Address(String address) {
    return _repository.bindWalletAddress(
      address: address,
      provider: _selectedProvider,
    );
  }

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
