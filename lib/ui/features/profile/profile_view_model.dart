import 'package:flutter/foundation.dart';

import '../../../data/repositories/crypto_repository.dart';
import '../../../domain/models/crypto_models.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
  }

  final CryptoRepository _repository;

  UserCryptoState get state => _repository.state;

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _repository.updateProfileSettings(displayName: trimmed);
  }

  Future<void> toggleNotifications(bool value) =>
      _repository.updateProfileSettings(notificationsEnabled: value);

  Future<void> toggleMiningAlerts(bool value) =>
      _repository.updateProfileSettings(miningAlertsEnabled: value);

  Future<void> toggleHaptics(bool value) =>
      _repository.updateProfileSettings(hapticsEnabled: value);

  Future<void> toggleBiometricLock(bool value) =>
      _repository.updateProfileSettings(biometricLockEnabled: value);

  Future<void> signOut() => _repository.signOut();

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
