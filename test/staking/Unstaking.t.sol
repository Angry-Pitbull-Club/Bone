pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./CommonStakedBase.sol";

contract Unstaking is CommonStakedBase {
    function setUp() public {
        _commonSetup();
    }

    function test_Unstake() public {
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp to withdraw.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        // Unstake the nft.
        bone.unstake(tokenID);

        // Assert that the original account is the ownerOfNFT.
        assertEq(mockAPC.ownerOf(tokenID), ownerOfNFT);

        vm.stopPrank();
    }

    function test_UnstakeBeforeOneDay() public {
        vm.startPrank(ownerOfNFT);

        // Assert user cannot unstake before the one day period.
        vm.expectRevert(bytes("ERC721StakingWithERC20Burnable: not staked long enough"));
        bone.unstake(tokenID);

        // Assert that `tokenID` is still in the staked pool.
        assertEq(mockAPC.ownerOf(tokenID), address(bone));

        vm.stopPrank();
    }


    function test_UnstakeNotOwnerOfNFT() public {
        // Pose as a user that does not own the NFT.
        vm.startPrank(notOwnerOfNFT);

        // Unstake the nft.
        vm.expectRevert(bytes("ERC721StakingWithERC20Burnable: unstake from incorrect owner or unstaked nft"));
        bone.unstake(tokenID);

        // Assert that `tokenID` is still in the staked pool.
        assertEq(mockAPC.ownerOf(tokenID), address(bone));

        vm.stopPrank();
    }

    function test_UnstakeClaimTokens() public {
        // Move forward 1 day according to the staked timestamp.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        vm.startPrank(ownerOfNFT);

        // Get initla balance of `ownerOfNFT`.
        uint256 initBal = bone.balanceOf(ownerOfNFT);
        // console2.log("initBal: ", initBal);

        // Unstake the nft.
        bone.unstake(tokenID);

        // Assert that the original account is the ownerOfNFT.
        assertEq(mockAPC.ownerOf(tokenID), ownerOfNFT);

        // Assert that `ownerOfNFT`'s balance increased by days * `ratePerDay`.
        assertEq(bone.balanceOf(ownerOfNFT), initBal + 1 * ratePerDay);

        vm.stopPrank();
    }

    function test_BatchUnstake() public {
        vm.startPrank(ownerOfNFT);

        // Move forward 1 day according to the staked timestamp to withdraw.
        vm.warp(1 days + bone.stakedTimestamp(ownerOfNFT, tokenID));

        // Batch unstake the nfts.
        bone.batchUnstake(tokenIDs);

        // Assert that all the tokens have been staked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the original account is the ownerOfNFT.
            assertEq(mockAPC.ownerOf(tokenIDs[i]), ownerOfNFT);
        }
    }
}    


