// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC3643 } from "@erc3643org/erc-3643/contracts/ERC-3643/IERC3643.sol";
import { AgentRole } from "@erc3643org/erc-3643/contracts/roles/AgentRole.sol";
import { Identity } from "@onchain-id/solidity/contracts/Identity.sol";
import { Test } from "forge-std/src/Test.sol";

import { AssetIdOracleFactory, AssetIdOracle } from "contracts/factories/AssetIdOracleFactory.sol";
import { TOPIC_NAV_PER_SHARE } from "contracts/libraries/ConstantsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { UtilsLib } from "contracts/libraries/UtilsLib.sol";

/// @dev Integration test on BASE SEPOLIA
contract AssetIdOracleIntegrationTest is Test {
    AggregatorV3Interface public usdcUsdOracle;
    AggregatorV3Interface public ethUsdOracle;

    IERC3643 public diplo;
    Identity public diploIdentity;

    AssetIdOracleFactory public assetIdOracleFactory;
    AssetIdOracle public assetIdOracleUsdc;
    AssetIdOracle public assetIdOracleEth;

    address public claimIssuer;
    uint256 public claimIssuerPk;

    constructor() {
        vm.createSelectFork("baseTestnet", 30873182);

        diplo = IERC3643(0xCb000aE697B8740f425CfC6BBe518D14ED29E4D9);
        diploIdentity = Identity(diplo.onchainID());

        usdcUsdOracle = AggregatorV3Interface(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165);
        ethUsdOracle = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);

        (claimIssuer, claimIssuerPk) = makeAddrAndKey("Claim Issuer");
    }

    function setUp() public {
        assetIdOracleFactory = new AssetIdOracleFactory(address(new AssetIdOracle()));
        assetIdOracleUsdc = AssetIdOracle(
            assetIdOracleFactory.createAssetIdOracle(address(diplo), address(usdcUsdOracle), "USDC / USD")
        );
        assetIdOracleEth = AssetIdOracle(
            assetIdOracleFactory.createAssetIdOracle(address(diplo), address(ethUsdOracle), "ETH / USD")
        );

        vm.startPrank(Ownable(address(diplo)).owner());
        AgentRole(address(diplo)).addAgent(address(this));
        AgentRole(address(diplo)).addAgent(claimIssuer);
        vm.stopPrank();
    }

    function testUsdcOracle() public view {
        (, int256 usdcOraclePrice, , , ) = usdcUsdOracle.latestRoundData();

        (uint256 assetIdPrice, uint256 assetIdDecimals) = _getAssetIdPrice();

        uint256 calculatedPriceInChainlinkOracleDecimals = UtilsLib.scalePrice(
            (assetIdPrice * uint256(usdcOraclePrice)) / 10 ** usdcUsdOracle.decimals(),
            uint8(assetIdDecimals),
            usdcUsdOracle.decimals()
        );
        uint256 calculatedPriceInAssetIdOracleDecimals = UtilsLib.scalePrice(
            calculatedPriceInChainlinkOracleDecimals,
            usdcUsdOracle.decimals(),
            assetIdOracleUsdc.decimals()
        );

        (, int256 assetIdOraclePrice, , , ) = assetIdOracleUsdc.latestRoundData();

        assertEq(calculatedPriceInAssetIdOracleDecimals, uint256(assetIdOraclePrice));
    }

    function testEthOracle() public view {
        (, int256 ethOraclePrice, , , ) = ethUsdOracle.latestRoundData();

        (uint256 assetIdPrice, uint256 assetIdDecimals) = _getAssetIdPrice();

        uint256 calculatedPriceInChainlinkOracleDecimals = UtilsLib.scalePrice(
            (assetIdPrice * uint256(ethOraclePrice)) / 10 ** ethUsdOracle.decimals(),
            uint8(assetIdDecimals),
            ethUsdOracle.decimals()
        );
        uint256 calculatedPriceInAssetIdOracleDecimals = UtilsLib.scalePrice(
            calculatedPriceInChainlinkOracleDecimals,
            ethUsdOracle.decimals(),
            assetIdOracleEth.decimals()
        );

        (, int256 assetIdOraclePrice, , , ) = assetIdOracleEth.latestRoundData();

        assertEq(calculatedPriceInAssetIdOracleDecimals, uint256(assetIdOraclePrice));
    }

    // ----- Helpers -----

    function _getAssetIdPrice() public view returns (uint256 _price, uint256 _decimals) {
        bytes32[] memory claimIds = diploIdentity.getClaimIdsByTopic(TOPIC_NAV_PER_SHARE);
        require(claimIds.length > 0, ErrorsLib.NoTopic(TOPIC_NAV_PER_SHARE));

        (, , , , bytes memory data, ) = diploIdentity.getClaim(claimIds[0]);
        (_price, _decimals, ) = abi.decode(data, (uint256, uint256, uint256));
    }
}
