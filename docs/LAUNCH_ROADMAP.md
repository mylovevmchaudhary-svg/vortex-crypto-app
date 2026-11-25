# Vortex Coin (VTX) — Real Crypto Project & 1B Airdrop Launch Roadmap

This blueprint shows how to turn this Flutter application into a **live, real BNB Smart Chain (BEP-20) crypto coin** with ad-funded liquidity and a verified 1,000,000,000 (1B) coin airdrop.

---

## Step 1: Customize Your Coin Identity (1 File)
Open `lib/core/config/token_config.dart` and update:
- `coinName`: e.g. `'Your Coin Name'`
- `coinSymbol`: e.g. `'YCN'`
- `totalSupply`: `2000000000` (2B total, with `1000000000` dedicated to the 1B Airdrop)
- `tokenContractAddress` & `airdropContractAddress`: fill after Step 2 deployment.

---

## Step 2: Deploy Your Real BEP-20 Smart Contracts
1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create `VortexToken.sol` from `contracts/VortexToken.sol`.
3. Update the token name/symbol in the constructor (`ERC20("Your Coin", "YCN")`) if needed.
4. Compile with Solidity `0.8.20` (`Enable Optimization: 200`).
5. Connect MetaMask to **BNB Smart Chain Testnet** (Chain ID `97`) first using free test BNB from a faucet.
6. Deploy `VortexToken` with 5 separate Gnosis Safe / cold vault addresses:
   - `airdropVault` (receives **1,000,000,000 tokens**)
   - `liquidityVault` (receives 400,000,000 tokens for PancakeSwap LP)
   - `ecosystemAdsVault` (receives 300,000,000 tokens)
   - `marketingVault` (receives 200,000,000 tokens)
   - `teamVestingVault` (receives 100,000,000 tokens)
7. Verify the contract source on [BscScan](https://bscscan.com/) so holders trust the fixed supply & zero-rug code.

---

## Step 3: Enable Real Google AdMob Rewarded Ads + Anti-Cheat SSV
Your app earns ad revenue while users watch ads for coins. That ad revenue funds your **PancakeSwap liquidity pool**!

1. Add `google_mobile_ads: ^5.2.0` to `pubspec.yaml`.
2. Add your AdMob App ID inside `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
   ```
3. Implement `AdMobRewardedAdsService extends AdsService` using `RewardedAd.load(...)` and pass `ServerSideVerificationOptions(userId: currentUserId)` so Google AdMob notifies your Supabase Edge Function directly (preventing fake ad claims).
4. Run `backend/supabase_schema.sql` in your Supabase project's SQL Editor to enable atomic server-side balances and `fn_credit_verified_ad_reward`.

---

## Step 4: Execute the 1B Coin Airdrop & Launch on PancakeSwap
1. **Freeze Snapshot**: Query `users` where `bsc_wallet_address IS NOT NULL` and `total_ads_watched >= 3` into `airdrop_snapshots`.
2. **Generate Merkle Tree**: Use `@openzeppelin/merkle-tree` (Node.js) on `[bsc_wallet_address, final_airdrop_wei]` pairs to output `merkleRoot` + per-user proofs.
3. **Deploy `contracts/VortexMerkleAirdrop.sol`**: Transfer the **1,000,000,000 tokens** from `airdropVault` into the `VortexMerkleAirdrop` contract.
4. **Launch Liquidity on PancakeSwap V2/V3**: Pair your `400,000,000` liquidity tokens with BNB/USDT generated from AdMob revenue and lock LP tokens via PinkSale / UNCX so investors see locked liquidity!
5. **Open Claims**: Users visit the **Airdrop** tab and claim their BEP-20 coins directly into MetaMask / Trust Wallet!
