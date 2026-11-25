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

  CryptoRepository get repository => _repository;
  UserCryptoState get state => _repository.state;
  OfferFilter get selectedFilter => _selectedFilter;

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

  Future<ActionResult> claimWatchedAd(AdRewardResult result) =>
      _repository.claimWatchedAd(result);

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
