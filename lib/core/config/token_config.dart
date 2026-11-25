/// Central configuration for your real crypto coin project.
///
/// Update this single file to customize your coin name, ticker,
/// 1B airdrop parameters, BNB Smart Chain contract details, and AdMob IDs.
class TokenConfig {
  const TokenConfig._();

  // Token Identity
  static const String coinName = 'Vortex Coin';
  static const String coinSymbol = 'VTX';
  static const String projectTagline = 'Mine • Watch Ads • Claim 1B Airdrop';

  // Tokenomics (BEP-20 Standard - 18 Decimals)
  static const String networkName = 'BNB Smart Chain';
  static const String networkShort = 'BEP-20';
  static const int chainId = 56; // 56 = BSC Mainnet, 97 = BSC Testnet
  static const int decimals = 18;

  // 2B Total Supply with a dedicated 1B (50%) Community Airdrop Pool
  static const double totalSupply = 2000000000;
  static const double airdropPoolTotal = 1000000000; // 1 Billion Coins
  static const double initialSimulatedClaimedPool = 384500000; // 38.45% mined/claimed

  // Pre-launch indicative reference price (updates after DEX liquidity launch)
  static const double indicativeListingPriceUsd = 0.012;

  // Replace with your deployed BEP-20 token & Merkle airdrop contract addresses
  static const String tokenContractAddress =
      '0x0000000000000000000000000000000000000000';
  static const String airdropContractAddress =
      '0x0000000000000000000000000000000000000000';
  static const bool isContractDeployed = false;

  // Earning & Ads Economics
  static const double baseMiningRatePerHour = 12.5;
  static const int miningSessionHours = 24;
  static const double tapRewardAmount = 1.0;
  static const int dailyTapLimit = 50;
  static const double standardAdReward = 50.0;
  static const double mysteryAdMinReward = 25.0;
  static const double mysteryAdMaxReward = 150.0;
  static const int dailyAdWatchLimit = 15;
  static const int boostHoursPerAd = 2;

  // Referral Program
  static const double tier1ReferralPercent = 15.0;
  static const double tier2ReferralPercent = 5.0;
  static const double instantReferralBonus = 250.0;

  // Google AdMob Production / Test IDs (Android)
  // Replace test IDs with your real AdMob IDs before Play Store release.
  static const String androidAdMobAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Backend API (Supabase / Custom REST)
  static const String backendBaseUrl = 'https://api.yourproject.com';
  static const String officialWebsite = 'https://vortexcoin.io';
  static const String explorerBaseUrl = 'https://bscscan.com';
}
