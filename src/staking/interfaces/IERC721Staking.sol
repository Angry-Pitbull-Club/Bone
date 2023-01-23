pragma solidity 0.8.17;

/**
 * @title Staking Interface for ERC721
 * @author 0xultimate
 * @notice Interface for contracts that implement staking.
 */
interface IERC721Staking {
    /**
     *  @dev Stake is emitted when `tokenID` is staked.
     */
    event Stake(address indexed owner, uint256 tokenID, uint256 timestamp);

    /**
     *  @dev Equivalent to multiple {Stake} events, where `owner` and `timestamp` 
     *  are all the same.
     */
    event StakeBatch(address indexed owner, uint256[] tokenIDs, uint256 timestamp);

    /**
     *  @dev Unstake is emitted when `owner` reclaims ownership of their `tokenID` from
     *  the staking pool.
     */
    event Unstake(address indexed owner, uint256 indexed tokenID);

    /**
     *  @dev Equivalent to multiple {Unstake} events, where `owner` and `timestamp` 
     *  are all the same.
     */
    event UnstakeBatch(address indexed owner, uint256[] tokenIDs);

    /**
     *  @dev stake transfers a users tokenID to the staking pool.
     * 
     *  Returns a boolean value representing the success of stake. 
     * 
     *  IMPORTANT: The user must have approved the token first for this to succeed.
     */
    function stake(uint256 tokenID) external returns (uint256);

    /**
     *  @dev batchStake transfers multiple tokenIDs of a user to the staking pool.
     * 
     *  Returns a boolean value representing the success of stake. 
     * 
     *  IMPORTANT: The user must have approved the token first for this to succeed.
     */
    function batchStake(uint256[] calldata tokenIDs) external returns (uint256);


    /**
     *  @dev unstake transfers a user an NFT tokenID from the staking pool.
     * 
     *  Returns a boolean value representing the success of stake. 
     */
    function unstake(uint256 tokenID) external returns (bool);
    
    /**
     *  @dev batchUnstake transfers multiple tokenIDs from the staking pool to a user.
     * 
     *  Returns a boolean value representing the success of stake. 
     */
    function batchUnstake(uint256[] calldata tokenIDs) external returns (bool);
    
}