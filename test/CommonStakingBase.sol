pragma solidity 0.8.17;

import "./fixtures/common/CommonTestBase.sol";
import "../src/staking/implementations/Bone.sol";
import "../src/mocks/AngryPitbullClubDummy.sol";

// CommonStakingBase is the base test contract for pre-staked NFTs.
// `ownerOfNFT` is minted token ID 0.
// `tokenIDs` is an array of token IDs that will be used in the tests.
// Only 1 APC is minted.
contract CommonStakingBase is CommonTestBase {
    Bone public bone;
    AngryPitbullClub public mockAPC;
    ERC721Staking public stakingContract;
    ERC721StakingWithERC20Burnable public stakingContractWithERC20Burnable;
    address ownerOfNFT; // The owner of the NFT we will be testing against.
    address notOwnerOfNFT;
    address randomAddress;
    uint256 tokenID; // The tokenID we will be testing against.
    uint256 ratePerDay = 10;
    uint256[] tokenIDs;
    uint256[] tokenIDs2;
    uint256 highestOwnedCount = 114;

    // To abi.decode the account.
    struct Account {
        uint256 totalCanClaim;
        uint256 lastClaimedTimestamp;
        EnumerableSet.UintSet pendingTokensForClaim;
    }

    function _commonSetup() public virtual {
        // Set up mock APC contract.
        mockAPC = new AngryPitbullClub("angrypitbullclub", "APC", "url", "");
        // Set up Bone contract.
        bone = new Bone(address(mockAPC), ratePerDay, "Bone", "BONE");
        // Set up ERC721StakingContract.
        stakingContract = new ERC721Staking(address(mockAPC));
        // Set up ERC721StakingWithERC20Burnable.
        stakingContractWithERC20Burnable = new ERC721StakingWithERC20Burnable(address(mockAPC), ratePerDay, "Bone", "BONE");

        // Set up owner of the NFT and the user we will be posing as.
        ownerOfNFT = TestAddress.account1;
        // Set up a user who is not the owner of the NFT.
        notOwnerOfNFT = TestAddress.account2; 
        // Set up a user who is not the owner of the NFT.
        randomAddress = TestAddress.account3; 
        // Set the tokenID to 0 since the counter starts at 0.
        tokenID = 0;
        // Initializes tokenIDs from 0 to `highestOwnedCount`.
        for (uint256 i = 0; i < highestOwnedCount; i++) {
            tokenIDs.push(i);
        }

        // Airdrop the user an NFT.
        mockAPC.airdropAngryPitbulls(1, ownerOfNFT);
        // Assert that the owner has an NFT.
        assertEq(mockAPC.balanceOf(ownerOfNFT), 1);
        // Assert that the owner owns `tokenID`.
        assertEq(mockAPC.tokenOfOwnerByIndex(ownerOfNFT, 0), tokenID);

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Set approval to the bone contract.
        mockAPC.setApprovalForAll(address(bone), true);
        // Set approval to the staking contract.
        mockAPC.setApprovalForAll(address(stakingContract), true);
        // Set approval to the staking contract with ERC20Burnable.
        mockAPC.setApprovalForAll(address(stakingContractWithERC20Burnable), true);

        // Stop posing as the owner of the NFT.
        vm.stopPrank();
    }

    // --- Helper functions ---

    function airdropToHighestOwnedCount() public {
        // Assert that highest owned count is greater than 0 because we need to batch stake more than 1 NFT.
        assertGt(highestOwnedCount, 0);
        // Airdrop the owner more NFTs.
        mockAPC.airdropAngryPitbulls(highestOwnedCount-1, ownerOfNFT);
        // Assert that the owner has the correct amount of NFTs.
        assertEq(mockAPC.balanceOf(ownerOfNFT), highestOwnedCount);
    }

    function getAccount(address _address) public view returns(uint256, uint256, uint256[] memory) {
        // Get the account.
        bytes memory accountBytes = stakingContractWithERC20Burnable.getAccount(_address);
        // Decode the account bytes.
        return abi.decode(accountBytes, (uint256, uint256, uint256[]));
    }
}