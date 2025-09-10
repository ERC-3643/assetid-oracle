// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { UtilsLib } from "contracts/libraries/UtilsLib.sol";

import { BaseUnitTest } from "./utils/BaseUnitTest.sol";

contract AssetIdOracleUnitTest is BaseUnitTest {
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
}
