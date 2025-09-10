// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Test } from "forge-std/src/Test.sol";

import { AssetIdOracleFactory, AssetIdOracle } from "contracts/factories/AssetIdOracleFactory.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { EventsLib } from "contracts/libraries/EventsLib.sol";

import { ERC3643Stub } from "../stubs/ERC3643Stub.sol";
import { OracleStub } from "../stubs/OracleStub.sol";

contract CreateAssetIdOracleUnitTest is Test {
    address public implementationReference;
    AssetIdOracleFactory public assetIdOracleFactory;

    ERC3643Stub public erc3643;
    OracleStub public assetPriceFeed;

    address public user1;
    address public user2;

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.prank(user2);
        erc3643 = new ERC3643Stub("TEST", "TST", address(0), address(0), address(0));

        assetPriceFeed = new OracleStub("Asset / USD", 8, 500_000_000);

        implementationReference = address(new AssetIdOracle());
        assetIdOracleFactory = new AssetIdOracleFactory(implementationReference);
    }

    function testCreateAssetIdOracleUnauthorizedReverts() public {
        vm.prank(user1);
        vm.expectRevert(ErrorsLib.Unauthorized.selector);
        assetIdOracleFactory.createAssetIdOracle(address(erc3643), address(assetPriceFeed), "Test Oracle");
    }

    function testCreateAssetIdOracleZeroAddressERC3643Reverts() public {
        vm.expectRevert(ErrorsLib.ZeroAddress.selector);
        assetIdOracleFactory.createAssetIdOracle(address(0), address(assetPriceFeed), "Test Oracle");
    }

    function testCreateAssetIdOracleNominalCaseFromAdmin() public {
        vm.expectEmit(false, true, true, true);
        emit EventsLib.AssetIdOracleCreated(address(0), address(erc3643), address(assetPriceFeed));

        address oracleAddress = assetIdOracleFactory.createAssetIdOracle(
            address(erc3643),
            address(assetPriceFeed),
            "Test Oracle"
        );
        assertTrue(oracleAddress != address(0));

        AssetIdOracle oracle = AssetIdOracle(oracleAddress);
        assertEq(address(oracle.identity()), erc3643.onchainID());
        assertEq(address(oracle.paymentTokenOracle()), address(assetPriceFeed));
        assertEq(oracle.description(), "Test Oracle");
    }

    function testCreateAssetIdOracleNominalCaseFromTokenOwner() public {
        vm.startPrank(user2);
        vm.expectEmit(false, true, true, true);
        emit EventsLib.AssetIdOracleCreated(address(0), address(erc3643), address(assetPriceFeed));

        address oracleAddress = assetIdOracleFactory.createAssetIdOracle(
            address(erc3643),
            address(assetPriceFeed),
            "Test Oracle"
        );
        vm.stopPrank();
        assertTrue(oracleAddress != address(0));

        AssetIdOracle oracle = AssetIdOracle(oracleAddress);
        assertEq(address(oracle.identity()), erc3643.onchainID());
        assertEq(address(oracle.paymentTokenOracle()), address(assetPriceFeed));
        assertEq(oracle.description(), "Test Oracle");
    }
}
