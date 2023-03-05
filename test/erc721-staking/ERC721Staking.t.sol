// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../CommonStakingBase.sol";

contract ERC721StakingTest is CommonStakingBase {
    function setUp() public {
        _commonSetup();
    }

    function testStake() public {
        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Stake the NFT.
        uint256 timestamp = stakingContract.stake(tokenID);
        // Get the current timestamp.
        uint256 currentBlockTimeStamp = block.timestamp;
        // Assert that the timestamp is correct.
        assertEq(timestamp, currentBlockTimeStamp, "Timestamp is not correct");
        // Assert that the NFT is staked.
        assertTrue(stakingContract.hasOwnerStaked(ownerOfNFT, tokenID));
        // Assert that the timestamp set in the contract is correct.
        assertEq(stakingContract.stakedTimestamp(ownerOfNFT, tokenID), timestamp);

        // Stop the prank.
        vm.stopPrank();
    }

    function testUnstake() public {
        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Stake the NFT.
        uint256 timestamp = stakingContract.stake(tokenID);
        // Assert that the NFT is staked.
        assertTrue(stakingContract.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");
        // Assert that the timestamp is correct.
        assertEq(stakingContract.stakedTimestamp(ownerOfNFT, tokenID), timestamp, "Timestamp is not correct");

        // Unstake the NFT.
        stakingContract.unstake(tokenID);
        // Assert that the original account is the ownerOfNFT.
        assertEq(mockAPC.ownerOf(tokenID), ownerOfNFT, "NFT is not owned by the original owner");
        // Assert that the NFT is unstaked.
        assertFalse(stakingContract.hasOwnerStaked(ownerOfNFT, tokenID), "Staking contract has not updated for unstake");

        // Stop the prank.
        vm.stopPrank();
    }

    // Tests that the unstake function reverts when the NFT is not staked.
    function testUnstake_Revert_NotStakedNFT() public {
        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Expect a revert when unstaking an NFT that is not staked.
        vm.expectRevert(bytes("ERC721Staking: unstake from incorrect owner or unstaked nft"));
        // Unstake the NFT.
        stakingContractWithERC20Burnable.unstake(tokenID);

        // Stop the prank.
        vm.stopPrank(); 
    }

    // Tests that the unstake function reverts when the staked NFT is not owned by msg.sender
    function testUnstake_Revert_UnownedStakedNFT() public {
        // Stake the NFT.
        testStake();

        // Pose as the non-owner of the staked NFT.
        vm.startPrank(notOwnerOfNFT);

        // Expect a revert when unstaking a staked NFT that is not owned by msg.sender.
        vm.expectRevert(bytes("ERC721Staking: unstake from incorrect owner or unstaked nft"));
        // Unstake the NFT.
        stakingContractWithERC20Burnable.unstake(tokenID);

        // Stop the prank.
        vm.stopPrank(); 
    }


    function testBatchStake() public {
        // Airdrop the owner more NFTs.
        airdropToHighestOwnedCount();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Batch stake the nfts.
        uint256 timestamp = stakingContract.batchStake(tokenIDs);
        // Get the current timestamp.
        uint256 currentBlockTimeStamp = block.timestamp;
        // Assert that the timestamp is correct.
        assertEq(timestamp, currentBlockTimeStamp, "Timestamp is not correct");
        // Assert that all the tokens have been staked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is staked.
            assertTrue(stakingContract.hasOwnerStaked(ownerOfNFT, tokenIDs[i]));
            // Assert that the timestamp is correct.
            assertEq(stakingContract.stakedTimestamp(ownerOfNFT, tokenIDs[i]), timestamp);
        }
        
        // Stop the prank.
        vm.stopPrank();
    }

    function testBatchUnstake() public {
        // Airdrop the owner more NFTs.
        airdropToHighestOwnedCount();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Batch stake the nfts.
        uint256 timestamp = stakingContract.batchStake(tokenIDs);
        // Assert that all the tokens have been staked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is staked.
            assertTrue(stakingContract.hasOwnerStaked(ownerOfNFT, tokenIDs[i]), "NFT is not staked");
            // Assert that the timestamp is correct.
            assertEq(stakingContract.stakedTimestamp(ownerOfNFT, tokenIDs[i]), timestamp, "Timestamp is not correct");
        }

        // Batch unstake the nfts.
        stakingContract.batchUnstake(tokenIDs);
        // Assert that all the tokens have been unstaked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is unstaked.
            assertTrue(!stakingContract.hasOwnerStaked(ownerOfNFT, tokenIDs[i]));
        }

        // Stop the prank.
        vm.stopPrank();
    }    
}