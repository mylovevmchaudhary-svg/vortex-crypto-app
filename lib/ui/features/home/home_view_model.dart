import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/crypto_repository.dart';
import '../../../data/services/ads_service.dart';
import '../../../domain/models/crypto_models.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required CryptoRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepoChanged);
    _syncTickerState();
  }

  final CryptoRepository _repository;
  Timer? _ticker;
  int _tapPulseTick = 0;
  bool _isLoadingAd = false;

  CryptoRepository get repository => _repository;
  UserCryptoState get state => _repository.state;
  DateTime get now => _repository.now;
  int get tapPulseTick => _tapPulseTick;
  bool get isLoadingAd => _isLoadingAd;

  void _onRepoChanged() {
    _syncTickerState();
    notifyListeners();
  }

  void _syncTickerState() {
    final shouldTick =
        state.miningActive || state.isBoostActiveAt(_repository.now);
    if (shouldTick && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        notifyListeners();
      });
    } else if (!shouldTick && _ticker != null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  double get pendingMining => state.pendingMiningSinceLastSync(now);
  double get currentHourlyRate => state.currentHourlyRate(now);
  bool get isBoostActive => state.isBoostActiveAt(now);

  Duration get miningRemaining {
    if (!state.miningActive || state.miningSessionEnd == null) {
      return Duration.zero;
    }
    final diff = state.miningSessionEnd!.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  double get miningSessionProgress {
    if (!state.miningActive || state.miningSessionEnd == null) {
      return 0.0;
    }
    const totalSeconds = 24 * 3600;
    final remainingSeconds = miningRemaining.inSeconds.clamp(0, totalSeconds);
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  Duration get boostRemaining {
    if (!isBoostActive || state.boost2xUntil == null) {
      return Duration.zero;
    }
    final diff = state.boost2xUntil!.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<ActionResult> startMining() => _repository.startMining();

  Future<ActionResult> claimMining() => _repository.claimPendingMining();

  Future<ActionResult> tapOrb() async {
    final result = await _repository.tapToEarn();
    if (result.success) {
      _tapPulseTick++;
      notifyListeners();
    }
    return result;
  }

  Future<ActionResult> watchAd(AdPlacement placement) async {
    if (_isLoadingAd) {
      return const ActionResult(
        success: false,
        message: 'Ad is already loading...',
      );
    }
    _isLoadingAd = true;
    notifyListeners();
    try {
      return await _repository.watchAndClaimAd(placement);
    } finally {
      _isLoadingAd = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }
}
