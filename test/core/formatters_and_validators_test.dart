import 'package:flutter_test/flutter_test.dart';
import 'package:vortex_crypto_app/core/utils/formatters.dart';
import 'package:vortex_crypto_app/core/utils/validators.dart';

void main() {
  group('AppFormatters', () {
    test('formats token amounts with commas and decimals', () {
      expect(AppFormatters.formatTokens(1234567.5, decimals: 2), '1,234,567.50');
      expect(AppFormatters.formatTokens(1000, decimals: 0), '1,000');
    });

    test('formats billion and million supply numbers compactly', () {
      expect(AppFormatters.formatCompact(1000000000), '1.00B');
      expect(AppFormatters.formatCompact(384500000), '384.50M');
      expect(AppFormatters.formatCompact(15200), '15.2K');
    });

    test('formats countdown durations and wallet addresses', () {
      expect(
        AppFormatters.formatCountdown(
          const Duration(hours: 2, minutes: 5, seconds: 9),
        ),
        '02:05:09',
      );
      expect(
        AppFormatters.shortenAddress(
          '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        ),
        '0x71C7...976F',
      );
    });
  });

  group('AppValidators', () {
    test('accepts valid 42-char BEP-20 EVM address', () {
      expect(
        AppValidators.validateBep20Address(
          '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        ),
        isNull,
      );
    });

    test('rejects invalid or zero BEP-20 addresses', () {
      expect(AppValidators.validateBep20Address(''), isNotNull);
      expect(AppValidators.validateBep20Address('abc123'), isNotNull);
      expect(
        AppValidators.validateBep20Address(
          '0x0000000000000000000000000000000000000000',
        ),
        isNotNull,
      );
    });

    test('validates referral invite codes', () {
      expect(AppValidators.validateReferralCode('VTX-88412'), isNull);
      expect(AppValidators.validateReferralCode('AB'), isNotNull);
    });
  });
}
