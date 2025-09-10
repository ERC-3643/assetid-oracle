// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

library EventsLib {
    event AssetIdOracleCreated(
        address indexed assetIdOracle,
        address indexed erc3643,
        address indexed paymentTokenOracle
    );
    event ImplementationReferenceSet(
        address indexed oldImplementationReference,
        address indexed newImplementationReference
    );
}
