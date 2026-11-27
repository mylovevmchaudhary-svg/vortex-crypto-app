/// Central configuration for your real crypto coin project.
///
/// Update this single file to customize your coin name, ticker,
/// 1B airdrop parameters, BNB Smart Chain contract details, and AdMob IDs.
class TokenConfig {
  const TokenConfig._();

  // Token Identity
  static const String coinName = 'Vortex Coin';
  static const String coinSymbol = 'VTX';
  static const String projectTagline = 'Mine • Watch Ads • 1B Airdrop';

  // Tokenomics (BEP-20 Standard - 18 Decimals)
  static const String networkName = 'BNB Smart Chain';
  static const String networkShort = 'BEP-20';
  static const int chainId = 56; // 56 = BSC Mainnet, 97 = BSC Testnet
  static const int decimals = 18;

  // 2B Total Supply with a dedicated 1B (50%) Community Airdrop Pool
  static const double totalSupply = 2000000000;
  static const double airdropPoolTotal = 1000000000; // 1 Billion Coins

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

  // Google AdMob IDs (Android)
  // Uses Google's official test Rewarded Ad unit ID until you replace it
  // with your live AdMob Rewarded Ad unit ID before Play Store launch.
  static const String androidAdMobAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Project Links
  static const String officialWebsite = 'https://vortexcoin.io';
  static const String telegramUrl = 'https://t.me/vortexcoin_official';
  static const String twitterUrl = 'https://x.com/vortexcoin_io';
  static const String youtubeUrl = 'https://youtube.com/@vortexcoin';
  static const String explorerBaseUrl = 'https://bscscan.com';
}
