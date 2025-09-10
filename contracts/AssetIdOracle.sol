// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { IERC3643 } from "@erc3643org/erc-3643/contracts/ERC-3643/IERC3643.sol";
import { IIdentity } from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

import { TOPIC_NAV_PER_SHARE } from "./libraries/ConstantsLib.sol";
import { ErrorsLib } from "./libraries/ErrorsLib.sol";
import { UtilsLib } from "./libraries/UtilsLib.sol";

/// @title AssetIdOracle
/// @notice Oracle to get the erc3643 -> USD value, using details from AssetID info and payment token -> USD oracle
contract AssetIdOracle is AggregatorV3Interface {
    /// @notice The identity contract
    IIdentity public immutable identity;
    /// @notice The payment token oracle
    AggregatorV3Interface public immutable paymentTokenOracle;
    /// @notice The description of the oracle
    string public description;

    /// @notice Constructor
    /// @param _erc3643 The erc3643 contract
    /// @param _paymentTokenOracle The payment token oracle, giving the price of the payment token in USD
    /// @param _description The description of this oracle
    constructor(address _erc3643, address _paymentTokenOracle, string memory _description) {
        identity = IIdentity(IERC3643(_erc3643).onchainID());
        paymentTokenOracle = AggregatorV3Interface(_paymentTokenOracle);
        description = _description;
    }

    /// @inheritdoc AggregatorV3Interface
    function decimals() external view returns (uint8) {
        return paymentTokenOracle.decimals();
    }

    /// @inheritdoc AggregatorV3Interface
    function version() external pure returns (uint256) {
        return 1;
    }

    /// @inheritdoc AggregatorV3Interface
    function getRoundData(
        uint80 /* _roundId */
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return latestRoundData();
    }

    /// @inheritdoc AggregatorV3Interface
    function latestRoundData()
        public
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (uint256 _value, uint256 _decimals, uint256 _timestamp) = _getInfos();
        return (0, int256(_getPrice(_value, _decimals)), _timestamp, _timestamp, 0);
    }

    /// @notice Get the value, decimals and timestamp from the identity contract
    /// @return _value The value
    /// @return _decimals The decimals
    /// @return _timestamp The timestamp
    function _getInfos() internal view returns (uint256 _value, uint256 _decimals, uint256 _timestamp) {
        bytes32[] memory claimIds = identity.getClaimIdsByTopic(TOPIC_NAV_PER_SHARE);
        require(claimIds.length > 0, ErrorsLib.NoTopic(TOPIC_NAV_PER_SHARE));

        (, , , , bytes memory data, ) = identity.getClaim(claimIds[0]);
        (_value, _decimals, _timestamp) = abi.decode(data, (uint256, uint256, uint256));
        require(_value > 0, ErrorsLib.InvalidPriceFeed());
    }

    /// @notice Get the price of the erc3643 in the payment token
    /// @param erc3643Value The value of the erc3643
    /// @param erc3643Decimals The decimals of the erc3643
    /// @return The price of the erc3643 in the payment token
    function _getPrice(uint256 erc3643Value, uint256 erc3643Decimals) internal view returns (uint256) {
        (, int256 paymentTokenValue, , , ) = paymentTokenOracle.latestRoundData();
        uint8 paymentTokenDecimals = paymentTokenOracle.decimals();

        return
            UtilsLib.scalePrice(
                (erc3643Value * uint256(paymentTokenValue)) / 10 ** paymentTokenDecimals,
                uint8(erc3643Decimals),
                paymentTokenDecimals
            );
    }
}
