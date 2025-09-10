// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Script, console } from "forge-std/src/Script.sol";
import { AssetIdOracle } from "contracts/AssetIdOracle.sol";

/// @dev Deploy the AssetIdOracle on BASE SEPOLIA
contract DeployAssetIdOracle is Script {

    address dpl = 0xCb000aE697B8740f425CfC6BBe518D14ED29E4D9;
    address chainlinkUsdcUsdOracle = 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165;

    function run() public {
        console.log("sender: ", msg.sender);

        vm.startBroadcast();

        AssetIdOracle assetIdOracle = new AssetIdOracle(dpl, chainlinkUsdcUsdOracle, "DPL / USD Oracle");
        console.log("AssetIdOracle: ", address(assetIdOracle));

        vm.stopBroadcast();
    }

}
