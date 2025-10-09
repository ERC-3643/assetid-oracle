// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Script, console } from "forge-std/src/Script.sol";

import { AssetIdOracle } from "contracts/AssetIdOracle.sol";
import { AssetIdOracleFactory } from "contracts/factories/AssetIdOracleFactory.sol";
import { IContractsDeployer, CONTRACTS_DEPLOYER_ADDRESS } from "scripts/IContractsDeployer.sol";

// forge script DeployAssetIdOracleFactory --account deployerKey --sender 0xcE2812836cc776129dE116d5fedA764bBd691142 --rpc-url $BASE_SEPOLIA_RPC --broadcast --slow
contract DeployAssetIdOracleFactory is Script {
    string public constant ASSET_ID_ORACLE_IMPLEMENTATION_REFERENCE = "AssetIdOracle_ImplementationReference_v1.0.0";
    string public constant ASSET_ID_ORACLE_FACTORY = "AssetIdOracleFactory_v0.0.2";

    IContractsDeployer public deployer = IContractsDeployer(CONTRACTS_DEPLOYER_ADDRESS);

    // solhint-disable no-console
    function run() public {
        console.log("sender: ", msg.sender);

        require(
            deployer.getContract(ASSET_ID_ORACLE_FACTORY) == address(0),
            "This version of AssetIdOracleFactory is already deployed"
        );

        vm.startBroadcast();

        address implementationReference = deployer.getContract(ASSET_ID_ORACLE_IMPLEMENTATION_REFERENCE);
        if (implementationReference == address(0)) {
            implementationReference = deployer.deployContract(
                ASSET_ID_ORACLE_IMPLEMENTATION_REFERENCE,
                abi.encodePacked(type(AssetIdOracle).creationCode)
            );
            console.log("AssetIdOracle Reference deployed: ", implementationReference);
        } else {
            console.log("AssetIdOracle Reference already deployed: ", implementationReference);
        }

        address factory = deployer.deployContract(
            ASSET_ID_ORACLE_FACTORY,
            abi.encodePacked(type(AssetIdOracleFactory).creationCode, abi.encode(implementationReference, msg.sender))
        );
        console.log("AssetIdOracleFactory: ", factory);

        vm.stopBroadcast();
    }
}
