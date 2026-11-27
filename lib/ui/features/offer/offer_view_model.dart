import 'package:flutter/foundation.dart';

import '../../../data/repositories/crypto_repository.dart';
import '../../../data/services/ads_service.dart';
import '../../../domain/models/crypto_models.dart';

enum OfferFilter {
  all,
  ads,
  social,
  partner,
}

class OfferViewModel extends ChangeNotifier {
  OfferViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
  }

  final CryptoRepository _repository;
  OfferFilter _selectedFilter = OfferFilter.all;
  AdPlacement? _loadingAdPlacement;

  CryptoRepository get repository => _repository;
  UserCryptoState get state => _repository.state;
  OfferFilter get selectedFilter => _selectedFilter;
  AdPlacement? get loadingAdPlacement => _loadingAdPlacement;

  List<EarnOffer> get filteredOffers {
    final all = state.offers;
    return switch (_selectedFilter) {
      OfferFilter.all => all,
      OfferFilter.ads =>
        all.where((o) => o.category == OfferCategory.ads).toList(),
      OfferFilter.social =>
        all.where((o) => o.category == OfferCategory.social).toList(),
      OfferFilter.partner =>
        all.where((o) => o.category == OfferCategory.partner).toList(),
    };
  }

  void selectFilter(OfferFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<ActionResult> claimDailyStreak() => _repository.claimDailyStreak();

  Future<ActionResult> completeOffer(String offerId) =>
      _repository.completeOffer(offerId);

  Future<ActionResult> watchAd(AdPlacement placement) async {
    if (_loadingAdPlacement != null) {
      return const ActionResult(
        success: false,
        message: 'Ad is already loading...',
      );
    }
    _loadingAdPlacement = placement;
    notifyListeners();
    try {
      return await _repository.watchAndClaimAd(placement);
    } finally {
      _loadingAdPlacement = null;
      notifyListeners();
    }
  }

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
