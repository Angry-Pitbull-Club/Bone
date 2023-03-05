// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IVendor.sol";
import "../../staking/interfaces/IERC721StakingWithERC20Burnable.sol";

contract AngryPitbullClubStore is IVendor, Ownable, ERC1155Burnable, ERC1155Supply {
    using Counters for Counters.Counter;

    Counters.Counter private _nextTokenIDCounter;

    struct ItemListing {
        bool purchaseable;
        uint256 price;
        uint256 totalSupply;
        uint256 bought;
    }

    mapping(uint256 => ItemListing) public vendor;
    mapping(address => bool) public acceptedTokens;

    constructor(string memory url_) ERC1155(url_) {}

    /**
     * @notice Buy item.
     */
    function buyItem(address tokenPaymentAddress, uint256 id, uint256 amount, bytes memory data) external override {
        require(acceptedTokens[tokenPaymentAddress], "using unaccepted token");
        require(vendor[id].purchaseable, "item is not for sale");
        require(vendor[id].bought + amount < vendor[id].totalSupply, "buying over available stock or sold out");

        _mint(msg.sender, id, amount, data);
        vendor[id].bought += amount;

        bool success = IERC20(tokenPaymentAddress).transferFrom(msg.sender, address(this), vendor[id].price * amount);
        if (success) {
            emit ItemBought(msg.sender, id, amount);
        }
    }

    /**
     * @notice Buy items in batch using the required token.
     */
    function buyItemsBatch(address tokenPaymentAddress, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external override {
        require(acceptedTokens[tokenPaymentAddress], "using unaccepted token");

        uint256 amountOwing;
        for (uint i = 0; i < ids.length; i++) {
            require(vendor[ids[i]].purchaseable, "item is not for sale");
            require(vendor[ids[i]].bought + amounts[i] < vendor[ids[i]].totalSupply, "buying over available stock or sold out");

            amountOwing += vendor[ids[i]].price * amounts[ids[i]];
        }
        _mintBatch(msg.sender, ids, amounts, data);

        bool success = IERC20(tokenPaymentAddress).transferFrom(msg.sender, address(this), amountOwing);
        if (success) {
            emit ItemBoughtBatch(msg.sender, ids, amounts);
        }
    }

    /**
     * @notice Allows the owner to create a new item in the store.
     */
    function createItem(uint256 price, uint256 totalSupply) external override onlyOwner {
        require(totalSupply > 0, "total supply <= 0");
        ItemListing memory newItem;

        newItem.price = price;
        newItem.totalSupply = totalSupply;
        newItem.bought = 0;
        vendor[_nextTokenIDCounter.current()] = newItem;
        _nextTokenIDCounter.increment();
    }

    /**
     * @notice Allows the owner to disable the purchaseability an item from the vendor.
     */
    function disableItemPurchaseability(uint256 id) external onlyOwner {
        require(vendor[id].totalSupply != 0, "removing non-existant item");
        vendor[id].purchaseable = false;
    }

    /**
     * @notice Allows the owner to enable the purchasability of an item in the vendor.
     */
    function enableItemPurchaseability(uint256 id) external onlyOwner {
        require(vendor[id].totalSupply != 0, "removing non-existant item");
        vendor[id].purchaseable = true;
    }

    /**
     * @notice Allows the owner to enable a token to be accepted as payment in the vendor.
     */
    function enableAcceptedToken(address tokenAddress) onlyOwner external {
        acceptedTokens[tokenAddress] = true;
    }

    /**
     * @notice Allows the owner to disable a token to be accepted as payment in the vendor.
     */
    function disableAcceptedToken(address tokenAddress) onlyOwner external {
        acceptedTokens[tokenAddress] = false;
    }

    /**
     * @notice Allows the owner to change the URI. 
     */
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
