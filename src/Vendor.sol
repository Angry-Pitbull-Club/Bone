// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract AngryPitbullClubStore is Ownable, ERC1155Burnable, ERC1155Supply {
    mapping(uint256 => bool) purchaseableItems;

    constructor(string url_) ERC1155(url_) {}

    /**
     * @notice Buy item.
     */
    function buyItem(uint256 id, bytes memory data) external returns (bool) {
       require (purchaseableItems[id], "item is not for sale");
       _mint(msg.sender, id, 1, data);
       return true;
    }

    /**
     * @notice Buy items in batch using the required token.
     */
    function buyItemsBatch(uint256[] memory ids, uint256[] memory amounts, bytes memory data) external {
        for (uint i = 0; i < ids.length; i++) {
            require (purchaseableItems[id], "item is not for sale");
        }
        _mintBatch(msg.sender, ids, amounts, data);
    }

    /**
     * @notice Allows the owner to create a new item in the store.
     */
    function createNewItem(uint256 id, bytes memory data) external onlyOwner returns (bool) {
        purchaseableItems[id] = true;
    }

    /**
     * @notice Allows the owner to remove an item from the store.
     */
    function removeItemFromStore(uint256 id) external onlyOwner returns (bool) {

    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
