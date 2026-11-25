import 'package:flutter/foundation.dart';

import '../../../data/repositories/crypto_repository.dart';
import '../../../domain/models/crypto_models.dart';

class AirdropViewModel extends ChangeNotifier {
  AirdropViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
  }

  final CryptoRepository _repository;

  UserCryptoState get state => _repository.state;
  List<AirdropRoadmapPhase> get phases => CryptoRepository.roadmapPhases;

  void _onRepoChanged() => notifyListeners();

  Future<ActionResult> registerSnapshotSpot() =>
      _repository.registerForAirdropSnapshot();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
