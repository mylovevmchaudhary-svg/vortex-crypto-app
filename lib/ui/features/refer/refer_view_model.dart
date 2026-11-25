import 'package:flutter/foundation.dart';

import '../../../core/config/token_config.dart';
import '../../../data/repositories/crypto_repository.dart';
import '../../../domain/models/crypto_models.dart';

class ReferViewModel extends ChangeNotifier {
  ReferViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
  }

  final CryptoRepository _repository;

  UserCryptoState get state => _repository.state;

  String get inviteLink =>
      '${TokenConfig.officialWebsite}/invite/${state.referralCode}';

  int get activeMinersCount =>
      state.referrals.where((member) => member.isActiveMiner).length;

  Future<ActionResult> applySponsorCode(String code) =>
      _repository.applySponsorReferralCode(code);

  Future<ActionResult> simulateFriendJoin(String name) =>
      _repository.inviteDemoFriend(name);

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
