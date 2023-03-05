// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../CommonStakingBase.sol";

contract ERC721StakingWithERC20BurnableTest is CommonStakingBase {
    function setUp() public {
        _commonSetup();
    }

    function testStake_NoneStaked() public {
        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Stake the NFT.
        uint256 timestamp = stakingContractWithERC20Burnable.stake(tokenID);
        // Assert that the NFT is staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");
        // Assert that the timestamp is correct.
        assertEq(stakingContractWithERC20Burnable.stakedTimestamp(ownerOfNFT, tokenID), timestamp, "The contract's state of timestamp of when NFT was staked is not correct");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim.
        assertEq(totalCanClaim, 1, "Account total can claim is not correct");
        // Assert last claimed timestamp is 0.
        assertEq(lastClaimedTimestamp, timestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");

        // Stop the prank.
        vm.stopPrank();
    }

    function testStake_StakeOneThenStakeAnotherOneSecondLater() public {
        // Airdrop the owner more NFTs.
        airdropToHighestOwnedCount();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);
        
        // Stake the NFT.
        uint256 initTimestamp = stakingContractWithERC20Burnable.stake(tokenID);
        // Assert that the NFT is staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");
        // Assert that the timestamp is correct.
        assertEq(stakingContractWithERC20Burnable.stakedTimestamp(ownerOfNFT, tokenID), initTimestamp, "Timestamp is not correct");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim.
        assertEq(totalCanClaim, 1, "Account total can claim is not correct");
        // Assert last claimed timestamp is 0.
        assertEq(lastClaimedTimestamp, initTimestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");

        // Move time forward.
        vm.warp(initTimestamp + 1);

        // Stake another NFT.
        uint256 timestamp = stakingContractWithERC20Burnable.stake(tokenID+1);
        // Assert that the NFT is staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID+1), "NFT is not staked");
        // Assert that the timestamp is correct.
        assertEq(stakingContractWithERC20Burnable.stakedTimestamp(ownerOfNFT, tokenID+1), timestamp, "Timestamp is not correct");

        // Get the account.
        (totalCanClaim, lastClaimedTimestamp, pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim is still 1.
        assertEq(totalCanClaim, 1, "Account total can claim is not correct");
        // Assert last claimed timestamp is still `initTimestamp`.
        assertEq(lastClaimedTimestamp, initTimestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length is now 1.
        assertEq(pendingTokensArray.length, 1, "Account pending tokens array length is not correct");
        // Assert pending tokens array is correct.
        assertEq(pendingTokensArray[0], tokenID+1, "Account pending tokens array is not correct");
        // Assert timestamps are different.
        assertFalse(initTimestamp == timestamp, "Timestamps are the same");

        // Stop the prank.
        vm.stopPrank();
    }

    function testUnstake_NoPending() public {
        // Stake the NFT.
        testStake_NoneStaked();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Unstake the NFT.
        stakingContractWithERC20Burnable.unstake(tokenID);
        // Assert that the NFT is marked as unstaked in the staking contract.
        assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is staked");
        // Assert that the original owner is the owner of the NFT.
        assertEq(mockAPC.ownerOf(tokenID), ownerOfNFT, "Owner of NFT is not correct");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim is 0.
        assertEq(totalCanClaim, 0, "Account total can claim is not correct");
        // Assert pending tokens array length is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");

        // Stop the prank.
        vm.stopPrank();
    }

    // Test unstaking an NFT that is in the `pendingTokensForClaim` pool.
    function testUnstake_PendingToken() public {
        // Stake the NFTs.
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Get the initial state of account.
        (uint256 initTotalCanClaim, uint256 initLastClaimedTimestamp, uint256[] memory initPendingTokensArray) = getAccount(ownerOfNFT);

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Unstake the NFT that is pending.
        stakingContractWithERC20Burnable.unstake(tokenID+1);
        // Assert that the NFT is marked as unstaked in the staking contract.
        assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID+1), "NFT is staked");
        // Assert that the original owner is the owner of the NFT.
        assertEq(mockAPC.ownerOf(tokenID+1), ownerOfNFT, "Owner of NFT is not correct");
 
        // Stop the prank.
        vm.stopPrank();

        // Get the current state of account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim is 1.
        assertEq(totalCanClaim, 1, "Account totalCanClaim is not correct");
        // Assert pending tokens last claimed timestamp is 0.
        assertEq(initLastClaimedTimestamp, lastClaimedTimestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");
    } 

    // Test unstake for a token in the `totalCanClaim` pool while there are pending tokens.
    function testUnstake_ClaimableTokenWithPending() public {
        // Stake the NFTs.
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Get the initial state of account.
        (uint256 initTotalCanClaim, uint256 initLastClaimedTimestamp, uint256[] memory initPendingTokensArray) = getAccount(ownerOfNFT);

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Unstake the NFT that is pending.
        stakingContractWithERC20Burnable.unstake(tokenID);
        // Assert that the NFT is marked as unstaked in the staking contract.
        assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is staked");
        // Assert that the original owner is the owner of the NFT.
        assertEq(mockAPC.ownerOf(tokenID), ownerOfNFT, "Owner of NFT is not correct");
 
        // Stop the prank.
        vm.stopPrank();

        // Get the current state of account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim is 0.
        assertEq(totalCanClaim, 0, "Account totalCanClaim is not correct");
        // Assert pending tokens last claimed timestamp is 0.
        assertEq(initLastClaimedTimestamp, lastClaimedTimestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length is 1.
        assertEq(pendingTokensArray.length, 1, "Account pending tokens array length is not correct");
    } 

    function testBatchStake() public {
        // Airdrop the owner more NFTs.
        airdropToHighestOwnedCount();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Batch stake the NFTs.
        uint256 timestamp = stakingContractWithERC20Burnable.batchStake(tokenIDs);
        // Assert that the NFTs are staked.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is marked as staked in the staking contract.
            assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenIDs[i]), "NFT is not staked");
            // Assert that the timestamp is correct.
            assertEq(stakingContractWithERC20Burnable.stakedTimestamp(ownerOfNFT, tokenIDs[i]), timestamp, "Timestamp is not correct");
            // Assert that the contract owns the NFT.
            assertEq(mockAPC.ownerOf(tokenIDs[i]), address(stakingContractWithERC20Burnable), "Owner of NFT is not correct");
        }

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert totalCanClaim is `highestOwnedCount` + 1.
        assertEq(totalCanClaim, highestOwnedCount, "Account totalCanClaim is not correct");
        // Assert `lastClaimedTimestamp` is current timestamp.
        assertEq(lastClaimedTimestamp, block.timestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");
        
        // Stop the prank.
        vm.stopPrank();
    }    

    function testBatchUnstake() public {
        testBatchStake();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Batch unstake the nfts.
        stakingContractWithERC20Burnable.batchUnstake(tokenIDs);
        // Assert that all the tokens have been unstaked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is marked as unstaked in the staking contract.
            assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenIDs[i]), "NFT is marked as staked");
            // Assert that the original owner is the owner of the NFT.
            assertEq(mockAPC.ownerOf(tokenIDs[i]), ownerOfNFT, "Owner of NFT is not correct");
        }

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert totalCanClaim is 0.
        assertEq(totalCanClaim, 0, "Account totalCanClaim is not correct");
        // Assert `lastClaimedTimestamp` is current timestamp.
        assertEq(lastClaimedTimestamp, block.timestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens is 0.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");

        // Stop the prank.
        vm.stopPrank();
    }  

    function testClaimTokens_TotalCanClaimOnly() public {
        // Batch Stake the NFTs.
        testBatchStake();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + stakingContractWithERC20Burnable.getLastClaimedTimestamp(ownerOfNFT));
        // Set expected token claim.
        uint256 expectedTokenClaim = ratePerDay * highestOwnedCount * 1 days/1 days;

        // Claim the tokens.
        stakingContractWithERC20Burnable.claimTokens();
        // Assert that the tokens have been claimed.
        assertEq(stakingContractWithERC20Burnable.balanceOf(ownerOfNFT), expectedTokenClaim, "Tokens have not been claimed");
        // Assert that the NFT is still staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert total can claim.
        assertEq(totalCanClaim, highestOwnedCount, "Account total can claim is not correct");
        // Assert last claimed timestamp.
        assertEq(lastClaimedTimestamp, block.timestamp, "Account last claimed timestamp is not correct");
        // Assert pending tokens array length.
        assertEq(pendingTokensArray.length, 0, "Account pending tokens array length is not correct");

        // Stop the prank.
        vm.stopPrank();
    }
  
    function testClaimTokens_StakeOneThenStakeAnotherOneSecondLater_Warp24hrs() public {
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + stakingContractWithERC20Burnable.getLastClaimedTimestamp(ownerOfNFT));
        // Set expected token claim.
        uint256 expectedTokenClaim = ratePerDay * 1; 

        // Claim the tokens.
        stakingContractWithERC20Burnable.claimTokens();
        // Assert that the tokens have been claimed.
        assertEq(stakingContractWithERC20Burnable.balanceOf(ownerOfNFT), expectedTokenClaim, "Tokens have not been claimed");
        // Assert that the NFT is still staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert `totalCanClaim` is 1.
        assertEq(totalCanClaim, 1, "`Account[msg.sender]totalCanClaim` is not correct");
        // Assert `lastClaimedTimestamp` is current timestamp.
        assertEq(lastClaimedTimestamp, block.timestamp, "`Account[msg.sender]lastClaimedTimestamp` is not correct");
        // Assert `pendingTokensArray.length` is 1.
        assertEq(pendingTokensArray.length, 1, "`Account[msg.sender]pendingTokensArray.length` is not correct");

        // Stop the prank.
        vm.stopPrank();
    }

    function testClaimTokens_StakeOneThenStakeAnotherOneSecondLater_Warp48hrs() public {
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp.
        vm.warp(2 days + stakingContractWithERC20Burnable.getLastClaimedTimestamp(ownerOfNFT));
        // Set expected token claim.
        uint256 expectedTokenClaim = ratePerDay * 3; 

        // Claim the tokens.
        stakingContractWithERC20Burnable.claimTokens();
        // Assert that the tokens have been claimed.
        assertEq(stakingContractWithERC20Burnable.balanceOf(ownerOfNFT), expectedTokenClaim, "Tokens have not been claimed");
        // Assert that the NFT is still staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is not staked");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert `totalCanClaim` is 2.
        assertEq(totalCanClaim, 2, "`Account[msg.sender]totalCanClaim` is not correct");
        // Assert `lastClaimedTimestamp` is current timestamp.
        assertEq(lastClaimedTimestamp, block.timestamp, "`Account[msg.sender]lastClaimedTimestamp` is not correct");
        // Assert `pendingTokensArray.length` is 0.
        assertEq(pendingTokensArray.length, 0, "`Account[msg.sender]pendingTokensArray.length` is not correct");

        // Stop the prank.
        vm.stopPrank();
    }

    function testClaimTokens_NothingStaked() public {
        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Claim the tokens. This should fail because nothing is staked.
        vm.expectRevert("ERC721StakingWithERC20Burnable: must stake first");
        stakingContractWithERC20Burnable.claimTokens();

        // Stop the prank.
        vm.stopPrank();
    }

    function testClaimTokens_ClaimingTooEarly() public {
        // Batch Stake the NFTs.
        testBatchStake();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Claim the tokens. This should fail because claiming too early.
        vm.expectRevert("ERC721StakingWithERC20Burnable: claiming too early");
        stakingContractWithERC20Burnable.claimTokens();

        // Stop the prank.
        vm.stopPrank();
    }

    function testClaimTokens_StakeOneThenStakeAnotherOneSecondLater_Warp24hrs_UnstakeTheFirst() public {
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Unstake the first NFT.
        stakingContractWithERC20Burnable.unstake(tokenID);
        // Assert that the NFT is not staked.
        assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is staked");

        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + stakingContractWithERC20Burnable.getLastClaimedTimestamp(ownerOfNFT));

        // Claim the tokens. This should fail because the first NFT is not staked.
        vm.expectRevert("ERC721StakingWithERC20Burnable: no tokens to mint");
        stakingContractWithERC20Burnable.claimTokens();

        // Stop the prank.
        vm.stopPrank();
    }

    function testClaimTokens_StakeOneThenStakeAnotherOneSecondLater_Warp48hrs_UnstakeTheFirst() public {
        testStake_StakeOneThenStakeAnotherOneSecondLater();

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Unstake the first NFT.
        stakingContractWithERC20Burnable.unstake(tokenID);
        // Assert that the NFT is not staked.
        assertFalse(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID), "NFT is staked");

        // Move forward 1 day according to the staked timestamp.
        vm.warp(2 days + stakingContractWithERC20Burnable.getLastClaimedTimestamp(ownerOfNFT));

        // Establish expected claims.
        uint256 expectedTokenClaim = ratePerDay;
        uint256 expectedTotalCanClaim = 1;
        uint256 expectedLastClaimedTimestamp = block.timestamp;
        uint256 expectedPendingTokensArrayLength = 0;
        // Claim the tokens. 
        stakingContractWithERC20Burnable.claimTokens();
        // Assert that the tokens have been claimed.
        assertEq(stakingContractWithERC20Burnable.balanceOf(ownerOfNFT), expectedTokenClaim, "Tokens have not been claimed");
        // Assert that the NFT is still staked.
        assertTrue(stakingContractWithERC20Burnable.hasOwnerStaked(ownerOfNFT, tokenID+1), "NFT is not staked");

        // Get the account.
        (uint256 totalCanClaim, uint256 lastClaimedTimestamp, uint256[] memory pendingTokensArray) = getAccount(ownerOfNFT);
        // Assert `totalCanClaim` is expected `totalCanClaim`.
        assertEq(totalCanClaim, expectedTotalCanClaim, "`Account[msg.sender]totalCanClaim` is not correct");
        // Assert `lastClaimedTimestamp` is expected timestamp.
        assertEq(lastClaimedTimestamp,expectedLastClaimedTimestamp, "`Account[msg.sender]lastClaimedTimestamp` is not correct");
        // Assert `pendingTokensArray.length` is `expectedPendingTokensArray.length`.
        assertEq(pendingTokensArray.length, expectedPendingTokensArrayLength, "`Account[msg.sender]pendingTokensArray.length` is not correct");

        // Stop the prank.
        vm.stopPrank();
    }
}