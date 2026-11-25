/// Validation helpers for BEP-20 addresses, referral codes, and user inputs.
class AppValidators {
  const AppValidators._();

  static final RegExp _evmAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
  static final RegExp _referralCodeRegex = RegExp(r'^[A-Z0-9\-]{4,16}$');

  /// Validates standard BSC (BEP-20) / Ethereum 20-byte hex wallet addresses.
  static String? validateBep20Address(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) {
      return 'Enter your BNB Smart Chain (BEP-20) wallet address.';
    }
    if (!value.startsWith('0x')) {
      return 'BEP-20 address must start with 0x.';
    }
    if (!_evmAddressRegex.hasMatch(value)) {
      return 'Invalid address format. Expected 42 hex characters (0x...).';
    }
    if (value == '0x0000000000000000000000000000000000000000') {
      return 'Zero address cannot receive airdrop tokens.';
    }
    return null;
  }

  static bool isValidBep20Address(String input) {
    return validateBep20Address(input) == null;
  }

  static String? validateReferralCode(String? input) {
    final value = input?.trim().toUpperCase() ?? '';
    if (value.isEmpty) {
      return 'Please enter an invite code.';
    }
    if (!_referralCodeRegex.hasMatch(value)) {
      return 'Invite code must be 4-16 alphanumeric characters.';
    }
    return null;
  }
}
