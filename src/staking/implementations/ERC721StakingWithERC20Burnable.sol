pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../implementations/ERC721Staking.sol";
import "forge-std/console2.sol";

/**
 * @title Extending {ERC721Staking} with burnable ERC20 tokens.
 * @author 0xultimate
 * @notice Intended for contracts to provide staking for ERC721 tokens 
 * that are already deployed and provide burnable ERC20 tokens to stakers.
 */
contract ERC721StakingWithERC20Burnable is ERC721Staking, ERC20Burnable {
    /**
     *  @dev Claim is emitted when `owner` claims `value` tokens from the staking pool.
     */
    event Claim(address indexed owner, uint256 value, uint256 timestamp);

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
     *  @dev claimTokens returns the number of tokens gathered through staking to 
     *  the owner of `tokenID`.
     */
    function claimTokens(uint256 tokenID) public virtual returns (uint256) {
		uint256 lastBlockTimestamp = stakedTimestamp(msg.sender, tokenID);
        require(lastBlockTimestamp != 0, "ERC721StakingWithERC20Burnable: not staked or not owner");

        uint256 tokensToMint = (block.timestamp - lastBlockTimestamp) * ratePerDay;
        uint256 timeElapsed = (block.timestamp - lastBlockTimestamp)/(1 days);
        // console2.log("lastBlockTimestamp: ", lastBlockTimestamp);
        // console2.log("block.timestamp: ", block.timestamp);
        // console2.log("timeElapsed: ", timeElapsed);
        require(timeElapsed > 0, "ERC721StakingWithERC20Burnable: not staked long enough");

        tokensToMint = tokensToMint/(1 days);
        ERC721Staking._setStakedTimestamp(msg.sender, tokenID, block.timestamp);
        _mint(msg.sender, tokensToMint);

        emit Claim(msg.sender, tokensToMint, block.timestamp);

        return tokensToMint;
    }

    /**
     *  @dev batchClaimTokens runs multiple {claimTokens} based on `tokenIDs`.
     */
    function batchClaimTokens(uint256[] calldata tokenIDs) public virtual {
        require(tokenIDs.length > 0);

        for (uint i = 0; i < tokenIDs.length; i++) {
            claimTokens(tokenIDs[i]);
        }
    }

    /**
     * @dev See {IERC721Staking.sol-unstake}.
     */
    function unstake(uint256 tokenID) public virtual override returns (bool) {
        require(hasOwnerStaked(msg.sender, tokenID), "ERC721StakingWithERC20Burnable: unstake from incorrect owner or unstaked nft");

        claimTokens(tokenID);

		IERC721(nftAddress).safeTransferFrom(
			address(this),
			msg.sender,
			tokenID
		);

		emit Unstake(msg.sender, tokenID);

        return true;
    }

    /**
     * @dev See {IERC721Staking.sol-batchUnstake}.
     */
    function batchUnstake(uint256[] calldata tokenIDs) public virtual override returns (bool) {
        require(tokenIDs.length > 0);

        for (uint i = 0; i < tokenIDs.length; i++) {
            unstake(tokenIDs[i]);
        }
        return true;
    }
}