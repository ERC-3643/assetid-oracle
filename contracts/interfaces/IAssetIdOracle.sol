// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { IIdentity } from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

/// @title IAssetIdOracle
/// @notice Interface for AssetIdOracle contract
interface IAssetIdOracle is AggregatorV3Interface {
    /// @notice The identity contract
    function identity() external view returns (IIdentity);

    /// @notice The payment token oracle
    function paymentTokenOracle() external view returns (AggregatorV3Interface);

    /// @notice The description of the oracle
    function description() external view returns (string memory);

    /// @notice Initialize the oracle
    /// @param _erc3643 The erc3643 contract
    /// @param _paymentTokenOracle The payment token oracle, giving the price of the payment token in USD
    /// @param _description The description of this oracle
    function initialize(address _erc3643, address _paymentTokenOracle, string memory _description) external;
}
