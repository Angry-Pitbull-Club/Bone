pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./CommonStakedBase.sol";

contract Claiming is CommonStakedBase {
    function setUp() public {
        _commonSetup();
    }

    function test_ClaimTokens1Day() public {
        vm.startPrank(ownerOfNFT);
        
        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        // Claim tokens.
        uint256 amount = bone.claimTokens(tokenID);
        
        // Assert the new amount is equal to what is returned by the claim.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, bone.balanceOf(ownerOfNFT));

        // Assert rate is working correctly.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, ratePerDay);

        // Assert the timestamp has been updated.
        assertEq(bone.stakedTimestamp(ownerOfNFT, tokenID), block.timestamp);

        vm.stopPrank();
    }

    function test_ClaimTokens1DayAnd1Second() public {
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day and 1 second according to the staked timestamp.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID) + 1);

        // Claim tokens.
        uint256 amount = bone.claimTokens(tokenID);
        
        // Assert the new amount is equal to what is returned by the claim.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, bone.balanceOf(ownerOfNFT));

        // Assert rate is working correctly.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, ratePerDay);

        // Assert the timestamp has been updated.
        assertEq(bone.stakedTimestamp(ownerOfNFT, tokenID), block.timestamp);

        vm.stopPrank();
    }

    function test_ClaimTokens1Week() public {
        vm.startPrank(ownerOfNFT);

        // Move forward 1 week according to the staked timestamp.
        vm.warp(7 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        // Claim tokens.
        uint256 amount = bone.claimTokens(tokenID);
        
        // Assert the new amount is equal to what is returned by the claim.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, bone.balanceOf(ownerOfNFT));

        // Assert rate is working correctly.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, ratePerDay * 7);

        // Assert the timestamp has been updated.
        assertEq(bone.stakedTimestamp(ownerOfNFT, tokenID), block.timestamp);

        vm.stopPrank();
    }

    function test_ClaimTokens1WeekAnd1Second() public {
        vm.startPrank(ownerOfNFT);

        // Move forward 1 week according to the staked timestamp.
        vm.warp(7 days + bone.stakedTimestamp(ownerOfNFT, tokenID) + 1);

        // Claim tokens.
        uint256 amount = bone.claimTokens(tokenID);
        
        // Assert the new amount is equal to what is returned by the claim.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, bone.balanceOf(ownerOfNFT));

        // Assert rate is working correctly.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(amount, ratePerDay * 7);

        // Assert the timestamp has been updated.
        assertEq(bone.stakedTimestamp(ownerOfNFT, tokenID), block.timestamp);

        vm.stopPrank();
    }

    function test_RevertNotStakedLongEnough() public {
        vm.startPrank(ownerOfNFT);

        // Assert that the user must stake for one day minimum.
        vm.expectRevert(bytes("ERC721StakingWithERC20Burnable: not staked long enough"));
        bone.claimTokens(tokenID);

        vm.stopPrank();
    }

    function test_RevertNotOwner() public {
        vm.startPrank(notOwnerOfNFT);
        
        // Assert that the user cannot claim tokens for an NFT that is staked 
        // in the pool that they do not own.
        vm.expectRevert(bytes("ERC721StakingWithERC20Burnable: not staked or not owner"));
        uint256 amount = bone.claimTokens(tokenID+1);
        
        // Assert that the returned uint256 from claim tokens is 0.
        assertEq(amount, 0);

        // Assert that the user's balance is 0.
        // IMPORTANT: We have an assumption in this test that is assured since
        // the previous state of the owner is 0.
        assertEq(bone.balanceOf(ownerOfNFT), 0);
 
        vm.stopPrank();
    }

    function test_RevertNotStaked() public {
        // Airdrop the owner another NFT that is not staked.
        uint256 newTokenID = mockAPC.airdropAngryPitbulls(1, ownerOfNFT);

        vm.startPrank(ownerOfNFT);

        // Assert that claim tokens is reverted for not having staked the token.
        vm.expectRevert(bytes("ERC721StakingWithERC20Burnable: not staked or not owner"));
        bone.claimTokens(newTokenID);

        vm.stopPrank();
    }

    /**
     * @dev Based on {setUp}, we assume that all NFTs have been staked at the same time.
     */
    function test_BatchClaimTokens() public {
        vm.startPrank(ownerOfNFT);

        // Calculate initial ERC20 balance of `ownerOfNFT`.
        uint256 initBal = bone.balanceOf(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        // Claim tokens.
        bone.batchClaimTokens(tokenIDs);
        
        // Assert that the correct amount of tokens have been claimed.
        assertEq(tokenIDs.length * 10, bone.balanceOf(ownerOfNFT) - initBal);

        // Assert that the tokens state is correct.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the tokens still exist in the staked pool.
            assertTrue(bone.hasOwnerStaked(ownerOfNFT, tokenIDs[i]));

            // Assert the timestamp has been updated.
            assertEq(bone.stakedTimestamp(ownerOfNFT, tokenIDs[i]), block.timestamp);
        }

        vm.stopPrank();
    }

}