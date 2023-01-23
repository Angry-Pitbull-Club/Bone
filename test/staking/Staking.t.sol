pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./CommonStakingBase.sol";

contract Staking is CommonStakingBase {
    function setUp() public {
        _commonSetup();
    }

    function test_stake() public {
        vm.startPrank(ownerOfNFT);

        // Set approval to the staking contract.
        mockAPC.setApprovalForAll(address(bone), true);

        // Stake the nft.
        uint256 timestamp = bone.stake(tokenID);

        // Assert that the NFT has been transferred to staking contract.
        assertEq(mockAPC.ownerOf(tokenID), address(bone));

        // Assert that the NFT is staked.
        assertTrue(bone.hasOwnerStaked(ownerOfNFT, tokenID)); 

        // Assert that the timestamp is correct.
        assertEq(bone.stakedTimestamp(ownerOfNFT, tokenID), timestamp);

        vm.stopPrank();
    }

    function testFail_stakeNotOwner() public {
        vm.startPrank(notOwnerOfNFT);

        // Set approval to the staking contract.
        bone.stake(tokenID);        

        vm.stopPrank();
    }

    function test_BatchStake() public {
        // Airdrop the owner 5 NFTs, totalling 6 in posession.
        mockAPC.airdropAngryPitbulls(highestOwnedCount, ownerOfNFT);

        vm.startPrank(ownerOfNFT);

        // Set approval to the staking contract.
        mockAPC.setApprovalForAll(address(bone), true);

        uint256 timestamp = bone.batchStake(tokenIDs);

        // Assert that all the tokens have been staked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is staked.
            assertTrue(bone.hasOwnerStaked(ownerOfNFT, tokenIDs[i]));

            // Assert that the timestamp is correct.
            assertEq(bone.stakedTimestamp(ownerOfNFT, tokenIDs[i]), timestamp);
        }
    }
}