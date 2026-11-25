import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/token_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/ads_service.dart';
import 'vortex_widgets.dart';

/// Displays a realistic Rewarded Ad experience before awarding coins.
Future<AdRewardResult?> showRewardedAdDialog({
  required BuildContext context,
  required AdsService adsService,
  required AdPlacement placement,
  int adDurationSeconds = 3,
}) {
  return showDialog<AdRewardResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _RewardedAdPlayerDialog(
      adsService: adsService,
      placement: placement,
      adDurationSeconds: adDurationSeconds,
    ),
  );
}

class _RewardedAdPlayerDialog extends StatefulWidget {
  const _RewardedAdPlayerDialog({
    required this.adsService,
    required this.placement,
    required this.adDurationSeconds,
  });

  final AdsService adsService;
  final AdPlacement placement;
  final int adDurationSeconds;

  @override
  State<_RewardedAdPlayerDialog> createState() =>
      _RewardedAdPlayerDialogState();
}

class _RewardedAdPlayerDialogState extends State<_RewardedAdPlayerDialog> {
  late int _secondsRemaining;
  late AdRewardResult _pendingReward;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.adDurationSeconds;
    _pendingReward =
        widget.adsService.generateRewardForPlacement(widget.placement);
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _secondsRemaining == 0;
    final progress = widget.adDurationSeconds == 0
        ? 1.0
        : (widget.adDurationSeconds - _secondsRemaining) /
            widget.adDurationSeconds;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderHighlight),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      container: true,
                      liveRegion: isComplete,
                      child: StatusPill(
                        label: isComplete ? 'REWARD UNLOCKED' : 'SPONSORED AD',
                        color: isComplete ? AppColors.success : AppColors.gold,
                        icon: isComplete ? Icons.verified : Icons.ondemand_video,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close Ad',
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isComplete
                      ? AppColors.success.withValues(alpha: 0.6)
                      : AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const VortexCoinEmblem(size: 56),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(
                      _pendingReward.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.placement == AdPlacement.mysteryCrate
                        ? isComplete
                            ? 'Crate opened! +${_pendingReward.rewardAmount.toStringAsFixed(0)} ${TokenConfig.coinSymbol}'
                            : 'Opening Mystery Crate (${TokenConfig.mysteryAdMinReward.toInt()}–${TokenConfig.mysteryAdMaxReward.toInt()} ${TokenConfig.coinSymbol})...'
                        : '+${_pendingReward.rewardAmount.toStringAsFixed(0)} ${TokenConfig.coinSymbol}${_pendingReward.boostHoursGranted > 0 ? ' + ${_pendingReward.boostHoursGranted}h 2x Speed' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.goldBright,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      semanticsLabel: 'Ad playback progress',
                      semanticsValue: '${(progress * 100).round()}%',
                      backgroundColor: AppColors.bgPrimary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? AppColors.success : AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isComplete
                        ? 'Verification ID: ${_pendingReward.verificationNonce}'
                        : 'Reward unlocks in $_secondsRemaining second${_secondsRemaining == 1 ? '' : 's'}...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GoldGradientButton(
              label: isComplete
                  ? 'Claim +${_pendingReward.rewardAmount.toStringAsFixed(0)} ${TokenConfig.coinSymbol}'
                  : 'Watching Ad ($_secondsRemaining s)...',
              icon: isComplete ? Icons.auto_awesome : Icons.hourglass_top,
              onPressed: isComplete
                  ? () => Navigator.of(context).pop(_pendingReward)
                  : null,
            ),
            if (!isComplete) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Closing early forfeits the reward.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
