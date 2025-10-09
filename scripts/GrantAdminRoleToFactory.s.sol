// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Script, console } from "forge-std/src/Script.sol";

import { AssetIdOracleFactory } from "contracts/factories/AssetIdOracleFactory.sol";
import { ADMIN_ROLE } from "contracts/libraries/ConstantsLib.sol";

// forge script GrantAdminRoleToFactory --account deployerKey --sender 0xcE2812836cc776129dE116d5fedA764bBd691142 --rpc-url $BASE_SEPOLIA_RPC --broadcast
contract GrantAdminRoleToFactory is Script {
    AssetIdOracleFactory public factory = AssetIdOracleFactory(0xb56156DE7B4976987be27C739Df3Ed0B497282E0);

    // solhint-disable no-console
    function run() public {
        address admin = 0x75E3bd7Be034Bb614eD98b3740C5ecC95F24A15F;

        bool hasRole = factory.hasRole(ADMIN_ROLE, msg.sender);
        console.log("Has role: ", hasRole);

        vm.startBroadcast();

        factory.grantRole(ADMIN_ROLE, admin);
        console.log("Admin role granted to factory for address: ", admin);

        vm.stopBroadcast();
    }
}
