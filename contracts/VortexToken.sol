// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

/**
 * @title VortexToken (VTX) - BNB Smart Chain BEP-20 Token
 * @notice Fixed-supply token (2,000,000,000 VTX) with 1,000,000,000 VTX (50%)
 *         dedicated to the Community Mining & 1B Airdrop Pool.
 * @dev Deploy on BNB Smart Chain Testnet (Chain ID 97) first, then BSC Mainnet (Chain ID 56).
 *      No mint() function exists after constructor: total supply is permanently capped.
 */
contract VortexToken is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 2_000_000_000 * 10 ** 18;
    uint256 public constant AIRDROP_POOL_ALLOCATION = 1_000_000_000 * 10 ** 18;
    uint256 public constant LIQUIDITY_ALLOCATION = 400_000_000 * 10 ** 18;
    uint256 public constant ECOSYSTEM_ADS_ALLOCATION = 300_000_000 * 10 ** 18;
    uint256 public constant MARKETING_STAKING_ALLOCATION = 200_000_000 * 10 ** 18;
    uint256 public constant TEAM_VESTING_ALLOCATION = 100_000_000 * 10 ** 18;

    constructor(
        address initialOwner,
        address airdropVault,
        address liquidityVault,
        address ecosystemAdsVault,
        address marketingVault,
        address teamVestingVault
    ) ERC20("Vortex Coin", "VTX") Ownable(initialOwner) {
        require(airdropVault != address(0), "Invalid airdropVault");
        require(liquidityVault != address(0), "Invalid liquidityVault");
        require(ecosystemAdsVault != address(0), "Invalid ecosystemAdsVault");
        require(marketingVault != address(0), "Invalid marketingVault");
        require(teamVestingVault != address(0), "Invalid teamVestingVault");

        _mint(airdropVault, AIRDROP_POOL_ALLOCATION);
        _mint(liquidityVault, LIQUIDITY_ALLOCATION);
        _mint(ecosystemAdsVault, ECOSYSTEM_ADS_ALLOCATION);
        _mint(marketingVault, MARKETING_STAKING_ALLOCATION);
        _mint(teamVestingVault, TEAM_VESTING_ALLOCATION);

        assert(totalSupply() == MAX_SUPPLY);
    }
}
