// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts@5.0.2/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

/**
 * @title VortexMerkleAirdrop - 1B Coin BEP-20 Airdrop Claim Contract
 * @notice Allows hundreds of thousands of verified app users to claim their
 *         1,000,000,000 VTX airdrop share on BNB Smart Chain using Merkle proofs.
 * @dev Users pay minimal BSC gas (~$0.03) when claiming to their bound 0x wallet.
 */
contract VortexMerkleAirdrop is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    bytes32 public merkleRoot;
    uint256 public claimDeadline;
    bool public claimsPaused;

    mapping(address => bool) public hasClaimed;

    event AirdropClaimed(address indexed account, uint256 amount);
    event MerkleRootUpdated(bytes32 indexed newRoot, uint256 newDeadline);
    event ClaimsPausedUpdated(bool paused);

    constructor(
        address tokenAddress,
        bytes32 initialMerkleRoot,
        uint256 initialClaimDeadline,
        address initialOwner
    ) Ownable(initialOwner) {
        require(tokenAddress != address(0), "Invalid token");
        require(initialClaimDeadline > block.timestamp, "Deadline must be future");

        token = IERC20(tokenAddress);
        merkleRoot = initialMerkleRoot;
        claimDeadline = initialClaimDeadline;
    }

    function setMerkleRoot(bytes32 newRoot, uint256 newDeadline) external onlyOwner {
        require(newDeadline > block.timestamp, "Invalid deadline");
        merkleRoot = newRoot;
        claimDeadline = newDeadline;
        emit MerkleRootUpdated(newRoot, newDeadline);
    }

    function setClaimsPaused(bool paused) external onlyOwner {
        claimsPaused = paused;
        emit ClaimsPausedUpdated(paused);
    }

    function claim(uint256 amount, bytes32[] calldata merkleProof) external nonReentrant {
        require(!claimsPaused, "Claims are paused");
        require(block.timestamp <= claimDeadline, "Claim window closed");
        require(!hasClaimed[msg.sender], "Already claimed");
        require(amount > 0, "Zero amount");

        // Double-hash leaf protects against second preimage attacks
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "Invalid Merkle proof");

        hasClaimed[msg.sender] = true;
        token.safeTransfer(msg.sender, amount);

        emit AirdropClaimed(msg.sender, amount);
    }

    function recoverUnclaimed(address recipient) external onlyOwner {
        require(block.timestamp > claimDeadline, "Claim window still active");
        require(recipient != address(0), "Invalid recipient");
        uint256 remaining = token.balanceOf(address(this));
        token.safeTransfer(recipient, remaining);
    }
}
