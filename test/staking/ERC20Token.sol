pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./CommonStakedBase.sol";

contract ERC20Token is CommonStakedBase {
    function setUp() public {
        _commonSetup();
    }

    function test_Airdrop() public {
        // Airdrop `ownerOfNFT` 10000 ERC20 tokens.
        bone.airdrop(ownerOfNFT, 10000);

        // Assert that the balance of `ownerOfNFT` is 10000.
        assertEq(bone.balanceOf(ownerOfNFT), 10000);

        // Assert that the total balance of the ERC20 token is 10000.
        assertEq(bone.totalSupply(), 10000);
    }

    function test_MultipleAirdrops() public {
        // Airdrop `ownerOfNFT` 10000 ERC20 tokens.
        bone.airdrop(ownerOfNFT, 10000);

        // Assert that the balance of `ownerOfNFT` is 10000.
        assertEq(bone.balanceOf(ownerOfNFT), 10000);

        // Assert that the total balance of the ERC20 token is 10000.
        assertEq(bone.totalSupply(), 10000); 

        // Airdrop this contract 10000 ERC20 tokens.
        bone.airdrop(randomAddress, 10000);

        // Assert that the balance of this contract is 10000.
        assertEq(bone.balanceOf(randomAddress), 10000);

        // Assert that the total balance of the ERC20 token is 20000.
        assertEq(bone.totalSupply(), 20000); 
    }

    function test_OnlyOwnerCanAirdrop() public {
        vm.startPrank(address(0));

        // Assert that only owner can airdrop.
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        bone.airdrop(ownerOfNFT, 10000);
    }

    function test_enableAddressToBurn() public {
        // Assert that this address cannot burn initally.
        assertFalse(bone.allowedAddressesToBurn(randomAddress));

        // Enable this contract to be able to burn.
        bone.enableAddressToBurn(randomAddress);

        // Assert that this address can now burn.
        assertTrue(bone.allowedAddressesToBurn(randomAddress));
    }

    function test_disableAddressToBurn() public {
        // Assert that this address cannot burn initally.
        assertFalse(bone.allowedAddressesToBurn(randomAddress));

        // Enable this contract to be able to burn.
        bone.enableAddressToBurn(randomAddress);

        // Assert that this address can now burn.
        assertTrue(bone.allowedAddressesToBurn(randomAddress));

        // Disable this contract to be able to burn.
        bone.disableAddressToBurn(randomAddress);

        // Assert that this address cannot burn.
        assertFalse(bone.allowedAddressesToBurn(randomAddress));
    }

    function test_Burn() public {
        // Assert that this address cannot burn initally.
        assertFalse(bone.allowedAddressesToBurn(randomAddress));

        // Enable this contract to be able to burn.
        bone.enableAddressToBurn(randomAddress);

        // Assert that this address can now burn.
        assertTrue(bone.allowedAddressesToBurn(randomAddress));

        // Airdrop `randomAddress` 10000 ERC20 tokens.
        bone.airdrop(randomAddress, 10000);

        // Impersonate the address that is permitted to burn.
        vm.startPrank(randomAddress);
        bone.burn(10000);

        // Assert that the balance is now 0 after burning.
        assertEq(bone.balanceOf(randomAddress), 0);

        vm.stopPrank();
    }

    function test_NotAllowedToBurn() public {
        // Assert that this address cannot burn initally.
        assertFalse(bone.allowedAddressesToBurn(randomAddress));

        // Impersonate the address that is permitted to burn.
        vm.startPrank(randomAddress);
        
        // Assert that burn is reverted with `not allowed to burn`.
        vm.expectRevert(bytes("not allowed to burn"));
        bone.burn(10000);

        vm.stopPrank();
    }
}