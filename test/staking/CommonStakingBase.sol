pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../fixtures/common/CommonTestBase.sol";

import "../../src/staking/implementations/Bone.sol";
import "../../src/mocks/AngryPitbullClubDummy.sol";

contract CommonStakingBase is CommonTestBase {
    Bone public bone;
    AngryPitbullClub public mockAPC;
    address ownerOfNFT; // The owner of the NFT we will be testing against.
    address notOwnerOfNFT;
    address randomAddress;
    uint256 tokenID; // The tokenID we will be testing against.
    uint256 ratePerDay = 10;
    uint256[] tokenIDs;
    uint256 highestOwnedCount = 114;

    function _commonSetup() public virtual {
        // Set up mock APC contract.
        mockAPC = new AngryPitbullClub("angrypitbullclub", "APC", "url", "");

        // Set up Bone contract.
        bone = new Bone(address(mockAPC), ratePerDay, "Bone", "BONE");

        // Set up owner of the NFT and the user we will be posing as.
        ownerOfNFT = TestAddress.account1;

        // Set up a user who is not the owner of the NFT.
        notOwnerOfNFT = TestAddress.account2; 

        // Set up a user who is not the owner of the NFT.
        randomAddress = TestAddress.account3; 

        // Airdrop the user an NFT.
        mockAPC.airdropAngryPitbulls(1, ownerOfNFT);

        // Set the tokenID to 0 since the counter starts at 0.
        tokenID = 0;

        // Initializes tokenIDs with 6 tokens.
        for (uint256 i = 0; i < highestOwnedCount; i++) {
            tokenIDs.push(i);
        }
    }
}