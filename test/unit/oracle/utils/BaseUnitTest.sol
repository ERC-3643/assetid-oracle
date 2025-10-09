// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Test } from "forge-std/src/Test.sol";

import { AssetIdOracleFactory, AssetIdOracle } from "contracts/factories/AssetIdOracleFactory.sol";

import { ComplianceStub } from "../../stubs/ComplianceStub.sol";
import { ERC20Stub } from "../../stubs/ERC20Stub.sol";
import { ERC3643Stub } from "../../stubs/ERC3643Stub.sol";
import { IdentityRegistryStub } from "../../stubs/IdentityRegistryStub.sol";
import { OracleStub } from "../../stubs/OracleStub.sol";
import { IdentityStub } from "../../stubs/IdentityStub.sol";

abstract contract BaseUnitTest is Test {
    uint256 public constant IDENTITY_USD_VALUE = 1_050_000_000; // 10.50 USD
    uint8 public constant IDENTITY_DECIMALS = 8;

    uint256 public constant ORACLE_USD_VALUE = 990_000; // 0.99 USD
    uint8 public constant ORACLE_DECIMALS = 6;

    AssetIdOracleFactory public assetIdOracleFactory;
    address public assetIdOracleImplementationReference;

    ERC20Stub public usdc;
    ERC20Stub public usdt;
    ERC20Stub public weth;

    ERC3643Stub public erc3643;
    IdentityRegistryStub public identityRegistry;
    ComplianceStub public compliance;
    IdentityStub public identity;
    OracleStub public assetPriceFeed;
    OracleStub public usdcUsdOracle;

    address public issuerSafe;
    address public user1;
    address public user2;

    AssetIdOracle public assetIdOracle;

    constructor() {
        // Tokens
        usdc = new ERC20Stub("USD Coin", "USDC", 6);
        vm.label(address(usdc), "USDC");
        usdt = new ERC20Stub("Tether USD", "USDT", 6);
        vm.label(address(usdt), "USDT");
        weth = new ERC20Stub("Wrapped Ether", "WETH", 18);
        vm.label(address(weth), "WETH");

        // Price feeds
        assetPriceFeed = new OracleStub("Asset / USD", 8, 500_000_000);
        vm.label(address(assetPriceFeed), "Asset Price Feed");

        usdcUsdOracle = new OracleStub("USDC / USD", ORACLE_DECIMALS, int256(ORACLE_USD_VALUE)); // 1 USDC = 0,99 USDC

        identity = new IdentityStub();
        identity.setValue(IDENTITY_USD_VALUE); // 10.50 USD
        identity.setDecimals(IDENTITY_DECIMALS);
        identity.setTimestamp(block.timestamp);

        // ERC3643
        identityRegistry = new IdentityRegistryStub();
        compliance = new ComplianceStub();
        erc3643 = new ERC3643Stub("ASSET", "AST", address(identityRegistry), address(compliance), address(identity));
        vm.label(address(erc3643), "ERC3643");

        // Issuer safe
        issuerSafe = makeAddr("Issuer Safe");
        // Users
        user1 = makeAddr("User 1");
        user2 = makeAddr("User 2");

        // AssetIdOracle
        assetIdOracleFactory = new AssetIdOracleFactory(address(new AssetIdOracle()), address(this));
        assetIdOracle = AssetIdOracle(
            assetIdOracleFactory.createAssetIdOracle(address(erc3643), address(usdcUsdOracle), "AssetIdOracle")
        );
    }

    function setUp() public virtual {}
}
