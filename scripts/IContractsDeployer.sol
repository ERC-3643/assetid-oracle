// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

address constant CONTRACTS_DEPLOYER_ADDRESS = 0xb52a36D21Bc70156AeD729Ade308F880d1707d47;

interface IContractsDeployer {
    function deployContract(string memory name, bytes memory bytecode) external returns (address);
    function getContract(string memory name) external view returns (address);
}
