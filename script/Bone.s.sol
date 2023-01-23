// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/mocks/AngryPitbullClubDummy.sol";
import "../src/staking/implementations/Bone.sol";

contract BoneScript is Script {
    Bone public bone;
    AngryPitbullClub public mockAPC;
    address ownerOfNFT; // The owner of the NFT we will be testing against.
    address notOwnerOfNFT;
    address randomAddress;
    uint256 tokenID; // The tokenID we will be testing against.
    uint256 ratePerDay = 10;

    function setUp() public {

    }

    function run() public {
        uint256 deployerPKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPKey);
         
        // Set up mock APC contract.
        mockAPC = new AngryPitbullClub("angrypitbullclub", "APC", "url", "");

        // Set up Bone contract.
        bone = new Bone(address(mockAPC), ratePerDay, "Bone", "BONE");

        // Airdrop the user an NFT.
        mockAPC.airdropAngryPitbulls(1, vm.envAddress("ACCOUNT_ONE"));

        // Set the tokenID to 0 since the counter starts at 0.
        tokenID = 0;

        vm.stopBroadcast();
    }
}
