# Vortex Coin (VTX) — Flutter Crypto Mining, Watch-to-Earn & 1B BEP-20 Airdrop App

A complete Web3 crypto application built with **Flutter (Material 3 Dark Cyber-Gold UI)**, paired with **BNB Smart Chain (BEP-20) Smart Contracts** and a **Supabase Anti-Cheat Backend Schema**.

## Features Included (All 6 Pages)
1. **Home (`lib/ui/features/home/`)**: Live 24-hour Cloud Mining Node, interactive Tap-to-Earn coin core, real-time pending reward counter, 2x Speed Ad Boost card, quick actions, and earning breakdown.
2. **Airdrop (`lib/ui/features/airdrop/`)**: Live **1,000,000,000 (1B) Coin Airdrop Pool** tracker, Pioneer Multiplier (`1.0x`–`2.5x`), 4-step eligibility checklist, Launch Roadmap, and custom-painted Tokenomics Donut Chart.
3. **Offer (`lib/ui/features/offer/`)**: Rewarded Video Ad Center (`Watch Ads +50 VTX`, `2x Boost Ad`, `Mystery Crate`), 7-day daily check-in streak ribbon, and filterable social/partner offerwall.
4. **Refer (`lib/ui/features/refer/`)**: Unique invite code & shareable link, 2-tier commissions (`15%` Tier 1 + `5%` Tier 2), milestone ladder, sponsor invite code input, and live mining team list.
5. **Wallet (`lib/ui/features/wallet/`)**: Pre-launch vault balance, strict `0x...` BEP-20 wallet binding (`MetaMask`, `Trust Wallet`, `Binance Web3`, `SafePal`), BSC contract specs, and filterable reward ledger.
6. **Profile (`lib/ui/features/profile/`)**: Pioneer identity & tier badge, anti-bot/KYC readiness, interactive Whitepaper & Launch Blueprint sheet, notification/haptic/security toggles, and demo reset.

## Project Structure
- `lib/core/` — `TokenConfig`, Cyber-Gold dark theme, formatters, BEP-20 validators
- `lib/domain/models/` — Immutable domain models & JSON persistence
- `lib/data/` — `StorageService`, `AdsService` (with AdMob SSV hook), `CryptoRepository`
- `lib/ui/` — Responsive 6-tab navigation shell + MVVM feature screens
- `contracts/` — `VortexToken.sol` (BEP-20 2B supply) & `VortexMerkleAirdrop.sol` (1B Merkle claim contract)
- `backend/supabase_schema.sql` — PostgreSQL + RLS + AdMob SSV RPC functions
- `docs/LAUNCH_ROADMAP.md` — End-to-end guide to deploying your coin, AdMob ads, 1B airdrop, and PancakeSwap launch
- `.github/workflows/build_apk.yml` — Automated CI workflow (`flutter analyze`, `flutter test`, and Release APK build)

## Getting Started
```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter analyze
flutter test
flutter run
```
