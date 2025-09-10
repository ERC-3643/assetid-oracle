// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { Test } from "forge-std/src/Test.sol";

import { AssetIdOracleFactory, AssetIdOracle } from "contracts/factories/AssetIdOracleFactory.sol";
import { ADMIN_ROLE } from "contracts/libraries/ConstantsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { EventsLib } from "contracts/libraries/EventsLib.sol";

contract SetImplementationReferenceUnitTest is Test {
    address public implementationReference;
    AssetIdOracleFactory public assetIdOracleFactory;

    address public user1;

    function setUp() public {
        user1 = makeAddr("user1");

        implementationReference = address(new AssetIdOracle());
        assetIdOracleFactory = new AssetIdOracleFactory(implementationReference);
    }

    function testSetImplementationReferenceNonAdminReverts() public {
        address newImplementation = address(new AssetIdOracle());

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, user1, ADMIN_ROLE)
        );
        assetIdOracleFactory.setImplementationReference(newImplementation);
    }

    function testSetImplementationReferenceZeroAddress() public {
        vm.expectRevert(ErrorsLib.ZeroAddress.selector);
        assetIdOracleFactory.setImplementationReference(address(0));
    }

    function testSetImplementationReferenceNominalCase() public {
        address newImplementation = address(new AssetIdOracle());

        vm.expectEmit(true, true, true, true);
        emit EventsLib.ImplementationReferenceSet(implementationReference, newImplementation);

        assetIdOracleFactory.setImplementationReference(newImplementation);
        assertEq(assetIdOracleFactory.implementationReference(), newImplementation);
    }
}
