// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract OracleStub is AggregatorV3Interface, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint8 public nbDecimals;
    int256 public price;
    string public sdescription;

    constructor(string memory _description, uint8 _nbDecimals, int256 _price) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);

        sdescription = _description;
        nbDecimals = _nbDecimals;
        price = _price;
    }

    function setPrice(int256 _price) external onlyRole(ADMIN_ROLE) {
        price = _price;
    }

    function decimals() external view override returns (uint8) {
        return nbDecimals;
    }

    function description() external view override returns (string memory) {
        return sdescription;
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(
        uint80 /* _roundId */
    )
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return latestRoundData();
    }

    function latestRoundData()
        public
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (0, price, block.timestamp, block.timestamp, 0);
    }
}
