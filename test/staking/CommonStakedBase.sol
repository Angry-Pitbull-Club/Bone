pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./CommonStakingBase.sol";

/**
 * @dev IMPORTANT: {Staking.t.sol} should be passing for contracts inheriting
 * {CommonStakedBase} to be valid as we call batchStake.
 */
contract CommonStakedBase is CommonStakingBase {
    function _commonSetup() public virtual override {
        super._commonSetup();
        // Airdrop the owner the highest ownership count of the NFT.
        mockAPC.airdropAngryPitbulls(highestOwnedCount, ownerOfNFT);

        // Pose as the owner of the NFT.
        vm.startPrank(ownerOfNFT);

        // Set approval to the staking contract.
        mockAPC.setApprovalForAll(address(bone), true);

        // Batch stake the nfts.
        uint256 timestamp = bone.batchStake(tokenIDs);

        // Assert that all the tokens have been staked correctly.
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            // Assert that the NFT is staked.
            assertTrue(bone.hasOwnerStaked(ownerOfNFT, tokenIDs[i]));

            // Assert that the timestamp is correct.
            assertEq(bone.stakedTimestamp(ownerOfNFT, tokenIDs[i]), timestamp);
        }

        vm.stopPrank();
    }
}