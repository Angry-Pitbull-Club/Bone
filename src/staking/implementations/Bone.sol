pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../implementations/ERC721StakingWithERC20Burnable.sol";

/**
 * @title Bone staking contract for Angry Pitbull Club.
 * @author 0xultimate
 */
contract Bone is ERC721StakingWithERC20Burnable, Ownable {
    /**
     * @dev Intended to be extensible and allow burning logic to be implemented 
     * into contracts that are developed later.
     */ 
    mapping(address => bool) public allowedAddressesToBurn;

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

    /**
     * @notice Burns tokens for external contracts.
     * @dev Only addresses where `allowedAddressesToBurn[address]` returns true
     * are permitted to burn.
     */
    function burn(uint256 amount) public override {
        require(allowedAddressesToBurn[msg.sender], "not allowed to burn");
        super.burn(amount);
    }

    function burnFromUnclaimedTokens(uint256 amount) external {
        require(allowedAddressesToBurn[msg.sender], "not allowed to burn");
    }

    /**
     * @notice Disables an address to be able to burn.
     * @dev Previous state for an operator does not matter.
     */
    function disableAddressToBurn(address operator) external onlyOwner {
        allowedAddressesToBurn[operator] = false;
    }

    /**
     * @notice Enables an address to be able to burn.
     * @dev Previous state for an operator does not matter.
     */
    function enableAddressToBurn(address operator) external onlyOwner {
        allowedAddressesToBurn[operator] = true;
    }
}