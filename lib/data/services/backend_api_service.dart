import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/backend_config.dart';
import '../../domain/models/crypto_models.dart';

/// Real Supabase REST client that syncs user accounts and BEP-20 wallet bindings
/// when [BackendConfig] credentials are configured.
class BackendApiService {
  BackendApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => <String, String>{
        'apikey': BackendConfig.supabaseAnonKey,
        'Authorization': 'Bearer ${BackendConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates',
      };

  Future<void> upsertUserProfile(UserCryptoState state) async {
    if (!BackendConfig.isConfigured || !state.isRegistered) return;
    final uri = Uri.parse('${BackendConfig.supabaseUrl}/rest/v1/users');
    try {
      await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'display_name': state.displayName,
              'email': state.email,
              'referral_code': state.referralCode,
              'bsc_wallet_address': state.boundWalletAddress,
              'wallet_provider': state.boundWalletProvider,
              'balance_vtx': state.balanceVtx,
              'ad_earned_vtx': state.adEarnedVtx,
              'mining_earned_vtx': state.miningEarnedVtx,
              'referral_earned_vtx': state.referralEarnedVtx,
              'offer_earned_vtx': state.offerEarnedVtx,
              'total_ads_watched': state.totalAdsWatched,
              'airdrop_registered': state.airdropRegistered,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Offline-safe: local storage keeps the user's progress intact.
    }
  }
}
