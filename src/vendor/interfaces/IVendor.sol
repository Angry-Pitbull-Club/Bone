pragma solidity 0.8.17;

interface IVendor {
    /**
     *  @dev 
     */
    event CreateItem(uint256 tokenID);

    /**
     *  @dev 
     */
    event RemoveItem(uint256 tokenID);

    /**
     *  @dev
     */
    event ItemBought(address indexed buyer, uint256 tokenID);

    /**
     *  @dev
     */
    event ItemBoughtBatch(address indexed buyer, uint256[] tokenIDs, uint256[] amounts);

    /**
     *  @dev 
     */
    function createItem(bytes memory data) external returns (bool);

    function removeItem(uint256 tokenID) external returns (bool);

    function buyItem(uint256 id, bytes memory data) external;

    function buyItemsBatch() external;
}