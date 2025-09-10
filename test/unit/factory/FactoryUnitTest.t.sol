// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Test } from "forge-std/src/Test.sol";

import { AssetIdOracleFactory, AssetIdOracle } from "contracts/factories/AssetIdOracleFactory.sol";
import { ADMIN_ROLE } from "contracts/libraries/ConstantsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

contract FactoryUnitTest is Test {
    function setUp() public {}

    function testConstructorInitialSetup() public {
        address implementation = address(new AssetIdOracle());
        AssetIdOracleFactory factory = new AssetIdOracleFactory(implementation);

        assertEq(factory.implementationReference(), implementation);
        assertTrue(factory.hasRole(ADMIN_ROLE, address(this)));
    }

    function testConstructorZeroAddressImplementationReference() public {
        vm.expectRevert(ErrorsLib.ZeroAddress.selector);
        new AssetIdOracleFactory(address(0));
    }
}
