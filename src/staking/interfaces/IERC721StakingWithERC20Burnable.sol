pragma solidity 0.8.17;

/**
 * @title Staking Interface for ERC721
 * @author 0xultimate
 * @notice Interface for contracts that implement staking.
 */
interface IERC721StakingWithERC20Burnable {
    /**
     * @dev Claim is emitted when `owner` claims `value` tokens from the staking pool.
     */
    event Claim(address indexed owner, uint256 value, uint256 timestamp);

    /**
     * @dev
     */
    function batchClaimTokens(uint256[] calldata tokenIDs) external;

    /**
     * @dev
     */
    function burn(uint256 amount) external;

    /**
     * @dev
     */
    function burnFrom(address account, uint256 amount) external;
}