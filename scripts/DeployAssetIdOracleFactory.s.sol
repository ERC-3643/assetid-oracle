// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Script, console } from "forge-std/src/Script.sol";

import { AssetIdOracle } from "contracts/AssetIdOracle.sol";
import { AssetIdOracleFactory } from "contracts/factories/AssetIdOracleFactory.sol";

interface IContractDeployer {
    function deployContract(string memory name, bytes memory bytecode) external returns (address);
}

contract DeployAssetIdOracleFactory is Script {
    IContractDeployer public contractDeployer = IContractDeployer(0xb52a36D21Bc70156AeD729Ade308F880d1707d47);

    // solhint-disable no-console
    function run() public {
        console.log("sender: ", msg.sender);

        vm.startBroadcast();

        address implementationReference = contractDeployer.deployContract(
            "AssetIdOracle_ImplementationReference_v1",
            abi.encodePacked(type(AssetIdOracle).creationCode)
        );
        console.log("AssetIdOracle Reference: ", address(implementationReference));

        address factory = contractDeployer.deployContract(
            "AssetIdOracleFactory_v1",
            abi.encodePacked(type(AssetIdOracleFactory).creationCode, abi.encode(implementationReference))
        );
        console.log("AssetIdOracleFactory: ", factory);

        vm.stopBroadcast();
    }
}
