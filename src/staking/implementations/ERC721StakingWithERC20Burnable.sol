pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../implementations/ERC721Staking.sol";
import "../interfaces/IERC721StakingWithERC20Burnable.sol";
import "forge-std/console2.sol";

/**
 * @title Extending {ERC721Staking} with burnable ERC20 tokens.
 * @author 0xultimate
 * @notice Intended for contracts to provide staking for ERC721 tokens 
 * that are already deployed and provide burnable ERC20 tokens to stakers.
 * @dev 
 */
contract ERC721StakingWithERC20Burnable is ERC721Staking, ERC20Burnable {
    using EnumerableSet for EnumerableSet.UintSet;
    /**
     * @dev Claim is emitted when `owner` claims `value` tokens from the staking pool.
     */
    event Claim(address indexed owner, uint256 value, uint256 timestamp);

    /**
     * @dev To optimize for calculating rewards, we do the following:
     * - track the total that can claim rewards,
     * - track the tokens availble for the next epoch.
     * 
     * We pop the tokens on `readyNextEpoch` the next time the user claims and
     * increment `totalCanClaim`. 
     * 
     * We do not need to track the timestamp since that is tracked inside of
     * {ERC721Staking.sol: _staked}.
     */
    struct Account {
        uint256 totalCanClaim;
        uint256 lastClaimedTimestamp;
        EnumerableSet.UintSet pendingTokensForClaim;
    }

    mapping(address => Account) internal Accounts;
    uint256 public ratePerDay;

    constructor(
        address nftAddress_, 
        uint256 ratePerDay_,
        string memory tokenName_,
        string memory tokenSymbol_
    ) ERC20(tokenName_, tokenSymbol_) ERC721Staking(nftAddress_) {
        ratePerDay = ratePerDay_;
    }

    /**
     * @dev Mints tokens to the user according to their `Account`.
     * It will also update any tokens in `Account.pendingTokensForClaim`.
     * IMPORTANT: Any tokens in `Account.pendingTokensForClaim`
     */
    function claimTokens() public virtual {
        require(Accounts[msg.sender].lastClaimedTimestamp != 0, "ERC721StakingWithERC20Burnable: must stake first");
        require(block.timestamp - Accounts[msg.sender].lastClaimedTimestamp >= 1 days, "ERC721StakingWithERC20Burnable: claiming too early");

        uint256 tokensToMint = 0;
        // Calculate yield from the `Accounts[msg.sender].totalCanClaim`.
        uint256 tokensToMintBeforeDivide = (block.timestamp - Accounts[msg.sender].lastClaimedTimestamp) * ratePerDay * Accounts[msg.sender].totalCanClaim;
        tokensToMint += tokensToMintBeforeDivide/(1 days);

        // Inspect tokens in the Account's pending pool.
        uint256 totalCanClaimIncrease = 0;
        uint256 pendingTokenLength = Accounts[msg.sender].pendingTokensForClaim.length();

        for (uint256 i = 0; i < pendingTokenLength; i++) {
            // We need to see the timestamp of when each pending token was staked to go back and recalculate the correct rewards.
            uint256 tokenID = Accounts[msg.sender].pendingTokensForClaim.at(i);
            uint256 tokenIDStakedTimestamp = _staked[msg.sender][tokenID];
            uint256 daysSinceStaked = (block.timestamp - tokenIDStakedTimestamp)/(1 days);
            // If the token was staked less than 1 day ago, we skip it.
            if (daysSinceStaked < 1) {
                continue;
            }

            uint256 currTokensToMint = daysSinceStaked * ratePerDay;
            // {EnumerableSet.sol} "swaps and pops" when calling remove. Knowing this, we can safely remove it and then decrement both
            // the index and the length of `pendingTokenLength` as we are effectively replicating the current state but removing the
            // the current token for the next iteration.
            Accounts[msg.sender].pendingTokensForClaim.remove(tokenID);
            // If i == 0, we stay at the beginning of the array i.e. i = 0.
            if (i > 0) {
                i -= 1;
            }
            pendingTokenLength -= 1;

            // Calculate the tokens to claim.
            tokensToMint += currTokensToMint;
            totalCanClaimIncrease += 1;
        }

        // Update the account.
        require(tokensToMint != 0, "ERC721StakingWithERC20Burnable: no tokens to mint");
        Accounts[msg.sender].totalCanClaim += totalCanClaimIncrease;
        Accounts[msg.sender].lastClaimedTimestamp = block.timestamp;

        _mint(msg.sender, tokensToMint);

        emit Claim(msg.sender, tokensToMint, block.timestamp);
    }

    /**
     * @dev If `from` has not staked, their `totalCanClaim` is incremented.
     * Else if `from` has already staked tokens, `tokenID` will be added to their `pendingTokensForClaim`.
     */
    function _beforeTokenStaked(address from, uint256 tokenID) internal virtual override {
        if (Accounts[from].lastClaimedTimestamp == block.timestamp) {
            Accounts[from].totalCanClaim += 1;
        } else if (Accounts[from].totalCanClaim == 0 && Accounts[from].pendingTokensForClaim.length() == 0) {
            Accounts[from].totalCanClaim = 1;
            Accounts[from].lastClaimedTimestamp = block.timestamp;
        } else {
            Accounts[from].pendingTokensForClaim.add(tokenID);
        }
    }

    /**
     * @dev If `from` has not staked, `tokenIDs` length is added immediately to their `totalCanClaim`.
     * Else if `from` has already staked tokens, `tokenIDs` will be added to their `pendingTokensForClaim`.
     */
    function _beforeTokenStakedBatch(address from, uint256[] memory tokenIDs) internal virtual override {
        if (Accounts[from].lastClaimedTimestamp == block.timestamp) {
            Accounts[from].totalCanClaim += tokenIDs.length;
        } else if (Accounts[from].totalCanClaim == 0 && Accounts[from].pendingTokensForClaim.length() == 0) {
            Accounts[from].totalCanClaim = tokenIDs.length;
            Accounts[from].lastClaimedTimestamp = block.timestamp;
        } else {
            for (uint i = 0; i < tokenIDs.length; i++) {
                Accounts[from].pendingTokensForClaim.add(tokenIDs[i]);
            }
        }
    }

    /**
     * @dev If the token is in the `totalCanClaim` pool for `from`, then their `totalCanClaim` is decremented.
     * Else, `tokenID` will be removed from their `pendingTokensForClaim`.
     */
    function _afterTokenUnstaked(address from, uint256 tokenID) internal virtual override {
        // If the token is in the pending pool, remove it.
        if (Accounts[from].pendingTokensForClaim.contains(tokenID)) {
            Accounts[from].pendingTokensForClaim.remove(tokenID);
        } else {
            // Else, decrement the totalCanClaim.
            Accounts[from].totalCanClaim -= 1;
        }
    }

    /** 
     * @dev For each token, if the token is in the `totalCanClaim` pool for `from`, then their `totalCanClaim` is decremented.
     * Else, `tokenID` will be removed from their `pendingTokensForClaim`.
     */
    function _afterTokenUnstakedBatch(address from, uint256[] memory tokenIDs) internal virtual override {
        // If the token is in the pending pool, remove it.
        for (uint i = 0; i < tokenIDs.length; i++) {
            if (Accounts[from].pendingTokensForClaim.contains(tokenIDs[i])) {
                Accounts[from].pendingTokensForClaim.remove(tokenIDs[i]);
                console2.log("Removed tokenID from pendingTokensForClaim", tokenIDs[i]);
            } else {
                // Else, decrement the totalCanClaim.
                Accounts[from].totalCanClaim -= 1;
            }
        }
    }



    // Functions for front-end calls.
    function getAccount(address _address) external view returns (bytes memory) {
        return abi.encode(Accounts[_address].totalCanClaim, Accounts[_address].lastClaimedTimestamp, Accounts[_address].pendingTokensForClaim.values());    
    }

    function getLastClaimedTimestamp(address _address) external view returns (uint256) {
        return Accounts[_address].lastClaimedTimestamp;
    }

    function getTotalCanClaim(address _address) external view returns (uint256) {
        return Accounts[_address].totalCanClaim;
    }


}