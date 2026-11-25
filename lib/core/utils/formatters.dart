/// Formatting utilities for token balances, supply milestones, and timers.
class AppFormatters {
  const AppFormatters._();

  /// Formats a numeric amount with thousands commas and optional decimals.
  static String formatTokens(double amount, {int decimals = 2}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final fixed = absAmount.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();

    for (var i = 0; i < intPart.length; i++) {
      final reverseIndex = intPart.length - i;
      buffer.write(intPart[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    final sign = isNegative ? '-' : '';
    if (decimals == 0 || parts.length == 1) {
      return '$sign${buffer.toString()}';
    }
    return '$sign${buffer.toString()}.${parts[1]}';
  }

  /// Formats large supply numbers concisely (e.g. 1.00B, 384.50M).
  static String formatCompact(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    }
    if (abs >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    }
    if (abs >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatTokens(amount, decimals: 0);
  }

  /// Formats USD estimated value cleanly.
  static String formatUsd(double amount) {
    return '\$${formatTokens(amount, decimals: 2)}';
  }

  /// Formats a [Duration] as HH:MM:SS.
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Shortens a 42-char EVM wallet address as 0x1234...ABCD.
  static String shortenAddress(String address) {
    if (address.length < 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Formats a timestamp into a readable relative label.
  static String formatRelativeTime(DateTime timestamp, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    return '${timestamp.year}-$month-$day';
  }
}
