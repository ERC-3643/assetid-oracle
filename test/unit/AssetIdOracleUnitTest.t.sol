// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AssetIdOracle } from "contracts/AssetIdOracle.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { UtilsLib } from "contracts/libraries/UtilsLib.sol";

import { ERC3643Stub } from "../stubs/ERC3643Stub.sol";
import { IdentityStub } from "../stubs/IdentityStub.sol";
import { OracleStub } from "../stubs/OracleStub.sol";
import { BaseUnitTest } from "./utils/BaseUnitTest.sol";

contract AssetIdOracleUnitTest is BaseUnitTest {
    uint256 public constant IDENTITY_USD_VALUE = 1_050_000_000; // 10.50 USD
    uint8 public constant IDENTITY_DECIMALS = 8;

    uint256 public constant ORACLE_USD_VALUE = 990_000; // 0.99 USD
    uint8 public constant ORACLE_DECIMALS = 6;

    AssetIdOracle public assetIdOracle;
    IdentityStub public identity;
    OracleStub public usdcUsdOracle;

    function setUp() public override {
        super.setUp();

        identity = new IdentityStub();
        identity.setValue(IDENTITY_USD_VALUE); // 10.50 USD
        identity.setDecimals(IDENTITY_DECIMALS);
        identity.setTimestamp(block.timestamp);

        erc3643 = new ERC3643Stub("TEST", "TST", address(identityRegistry), address(compliance), address(identity));

        usdcUsdOracle = new OracleStub("USDC / USD", ORACLE_DECIMALS, int256(ORACLE_USD_VALUE)); // 1 USDC = 0,99 USDC
        assetIdOracle = new AssetIdOracle(address(erc3643), address(usdcUsdOracle), "AssetIdOracle");
    }

    function testDecimals() public view {
        assertEq(assetIdOracle.decimals(), 6);
    }

    function testVersion() public view {
        assertEq(assetIdOracle.version(), 1);
    }

    function testLatestRoundData() public view {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = assetIdOracle
            .latestRoundData();
        assertEq(roundId, 0);
        assertEq(
            uint256(answer),
            UtilsLib.scalePrice(
                (IDENTITY_USD_VALUE * ORACLE_USD_VALUE) / 10 ** ORACLE_DECIMALS,
                IDENTITY_DECIMALS,
                ORACLE_DECIMALS
            )
        );
        assertEq(startedAt, block.timestamp);
        assertEq(updatedAt, block.timestamp);
        assertEq(answeredInRound, 0);
    }

    function testGetRoundData() public view {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = assetIdOracle
            .getRoundData(0);
        assertEq(roundId, 0);
        assertEq(
            uint256(answer),
            UtilsLib.scalePrice(
                (IDENTITY_USD_VALUE * ORACLE_USD_VALUE) / 10 ** ORACLE_DECIMALS,
                IDENTITY_DECIMALS,
                ORACLE_DECIMALS
            )
        );
        assertEq(startedAt, block.timestamp);
        assertEq(updatedAt, block.timestamp);
        assertEq(answeredInRound, 0);
    }

    function testRevertIfNoTopic() public {
        identity.setTopicInvalidStatus(true);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.NoTopic.selector, 1_000_003));
        assetIdOracle.latestRoundData();
    }

    function testRevertIfPriceFeedIsZero() public {
        identity.setValue(0);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.InvalidPriceFeed.selector));
        assetIdOracle.latestRoundData();
    }

    // ----- Helpers -----

    function _initNominalCase() internal {
        usdc.mint(user1, 1_000_000 * 10 ** usdc.decimals());
        usdc.mint(issuerSafe, 1_000_000 * 10 ** usdc.decimals());
        erc3643.mint(user1, 100 * 10 ** erc3643.decimals());

        identityRegistry.setVerified(user1, true);
        compliance.setCanTransfer(address(0), user1, true);
        compliance.setCanTransfer(user1, address(0), true);
    }

    function _getUsdcAmount(uint256 amount) internal view virtual returns (uint256 usdcAmount) {
        usdcAmount = UtilsLib.scalePrice(
            (amount * IDENTITY_USD_VALUE * ORACLE_USD_VALUE) / 10 ** ORACLE_DECIMALS / 10 ** erc3643.decimals(),
            IDENTITY_DECIMALS,
            usdc.decimals()
        );
    }
}
