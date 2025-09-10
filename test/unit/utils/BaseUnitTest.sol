// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Test } from "forge-std/src/Test.sol";

import { ComplianceStub } from "../../stubs/ComplianceStub.sol";
import { ERC20Stub } from "../../stubs/ERC20Stub.sol";
import { ERC3643Stub } from "../../stubs/ERC3643Stub.sol";
import { IdentityRegistryStub } from "../../stubs/IdentityRegistryStub.sol";
import { OracleStub } from "../../stubs/OracleStub.sol";

abstract contract BaseUnitTest is Test {
    ERC20Stub public usdc;
    ERC20Stub public usdt;
    ERC20Stub public weth;

    OracleStub public assetPriceFeed;

    ERC3643Stub public erc3643;
    IdentityRegistryStub public identityRegistry;
    ComplianceStub public compliance;

    address public issuerSafe;
    address public user1;
    address public user2;

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

        // ERC3643
        identityRegistry = new IdentityRegistryStub();
        compliance = new ComplianceStub();
        erc3643 = new ERC3643Stub("ASSET", "AST", address(identityRegistry), address(compliance), address(0));
        vm.label(address(erc3643), "ERC3643");

        // Issuer safe
        issuerSafe = makeAddr("Issuer Safe");
        // Users
        user1 = makeAddr("User 1");
        user2 = makeAddr("User 2");
    }

    function setUp() public virtual {}
}
