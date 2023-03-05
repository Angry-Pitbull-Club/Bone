pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../implementations/ERC721StakingWithERC20Burnable.sol";
import "../interfaces/IBone.sol";
import "../../lib/EIP712.sol";

/**
 * @title Bone staking contract for Angry Pitbull Club.
 * @author 0xultimate
 */
contract Bone is IBone, ERC721StakingWithERC20Burnable, Ownable {
    constructor(
        address nftAddress_, 
        uint256 ratePerDay_,
        string memory tokenName_,
        string memory tokenSymbol_
    ) 
        ERC721StakingWithERC20Burnable(
            nftAddress_,
            ratePerDay_, 
            tokenName_,
            tokenSymbol_
        ) 
    {}

    /**
     * @notice Airdrops an `amount` of tokens to the `to` address.
     */
    function airdrop(address to, uint256 amount) onlyOwner external {
        _mint(to, amount);
    }

    // TODO: Implement claimAirdrop() function.
    function claimAirdrop() external {

    }
}