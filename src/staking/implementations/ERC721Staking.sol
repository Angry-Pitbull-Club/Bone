pragma solidity 0.8.17;

import "../interfaces/IERC721Staking.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Staking ERC721 tokens for contracts.
 * @author 0xultimate
 * @notice Intended for contracts to provide staking for ERC721 tokens that are already deployed.
 * @dev Implements only the staking mechanism with no rewards mechanism.
 */
contract ERC721Staking is IERC721Staking, IERC721Receiver {
    address public nftAddress;

    // Mapping owner to token ID to block timestamp
    mapping(address => mapping(uint256 => uint256)) internal _staked;

    /**
     * @dev Initializes the contract by setting an `nftAddress` to the NFT contract.
     */
    constructor(address nftAddress_) {
        // TODO: inspect this more
        require(nftAddress == address(0), "ERC721Staking: must set an address");

        nftAddress = nftAddress_;
    }

    /**
     * @dev See {IERC721Staking.sol-stake}.
     */
    function stake(uint256 tokenID) public virtual override returns (uint256) {
        _setStakedTimestamp(msg.sender, tokenID, block.timestamp);
        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID
        );

        emit Stake(msg.sender, tokenID, block.timestamp);
        return block.timestamp;
    }

    /**
     * @dev See {IERC721Staking.sol-batchStake}
     */
    function batchStake(uint256[] calldata tokenIDs) public virtual override returns (uint256) {
        require(tokenIDs.length > 0);

        for (uint i = 0; i < tokenIDs.length; i++) {
            stake(tokenIDs[i]);
        }
        return block.timestamp;
    }
    
    /**
     * @dev See {IERC721Staking.sol-unstake}.
     */
    function unstake(uint256 tokenID) public virtual override returns (bool) {
        require(hasOwnerStaked(msg.sender, tokenID), "ERC721Staking: unstake from incorrect owner or unstaked nft");

        _setStakedTimestamp(msg.sender, tokenID, 0);
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

    /**
     * @notice Only the contract can set the timestamp for staked NFTs.
     * @dev Sets the staked timestamp for the user. Can only be called internally.
     */
    function _setStakedTimestamp(address owner, uint256 tokenID, uint256 timestamp) internal virtual {
        _staked[owner][tokenID] = timestamp;
    }

    /**
     * @notice Informs you whether a specific `tokenID` has been staked by an address.
     * @dev This is used also as a modifier of sorts for unstake. Useful for frontend applications.
     */
    function hasOwnerStaked(address address_, uint256 tokenID) public view virtual returns (bool) {
        return _staked[address_][tokenID] != 0;
    }

    /**
     * @notice Informs you of the timestamp an `address_` staked a specific `tokenID`.
     * @dev Returns the timestamp of a staked NFT. Useful for frontend applications.
     */
    function stakedTimestamp(address address_, uint256 tokenID) public view virtual returns (uint256) {
        return _staked[address_][tokenID];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenID,
        bytes calldata data
    ) public pure override returns (bytes4) {
		return IERC721Receiver.onERC721Received.selector;
	}

}