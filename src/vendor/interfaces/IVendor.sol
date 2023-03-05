pragma solidity 0.8.17;

interface IVendor {
    /**
     * @dev 
     */
    event CreateItem(uint256 tokenID);

    /**
     * @dev 
     */
    event RemoveItem(uint256 tokenID);

    /**
     * @dev 
     */
    event ItemBought(address indexed buyer, uint256 tokenID, uint256 amount);

    /**
     * @dev 
     */
    event ItemBoughtBatch(address indexed buyer, uint256[] tokenIDs, uint256[] amounts);

    /**
     * @dev 
     */
    function createItem(uint256 price, uint256 totalSupply) external;

    /**
     * @dev 
     */
    function buyItem(address tokenPaymentAddress, uint256 id, uint256 amount, bytes memory data) external;

    /**
     * @dev 
     */
    function buyItemsBatch(address tokenPaymentAddress, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

}