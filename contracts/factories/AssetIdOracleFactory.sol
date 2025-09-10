// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { AssetIdOracle } from "../AssetIdOracle.sol";

import { ADMIN_ROLE } from "../libraries/ConstantsLib.sol";
import { ErrorsLib } from "../libraries/ErrorsLib.sol";
import { EventsLib } from "../libraries/EventsLib.sol";

contract AssetIdOracleFactory is AccessControl {
    address public implementationReference;

    constructor(address _implementationReference) {
        require(_implementationReference != address(0), ErrorsLib.ZeroAddress());

        _grantRole(ADMIN_ROLE, msg.sender);

        setImplementationReference(_implementationReference);
    }

    function createAssetIdOracle(
        address _erc3643,
        address _paymentTokenOracle,
        string memory _description
    ) external returns (address) {
        require(_erc3643 != address(0), ErrorsLib.ZeroAddress());
        require(hasRole(ADMIN_ROLE, msg.sender) || Ownable(_erc3643).owner() == msg.sender, ErrorsLib.Unauthorized());

        AssetIdOracle assetIdOracle = AssetIdOracle(Clones.clone(implementationReference));
        assetIdOracle.initialize(_erc3643, _paymentTokenOracle, _description);

        emit EventsLib.AssetIdOracleCreated(address(assetIdOracle), _erc3643, _paymentTokenOracle);

        return address(assetIdOracle);
    }

    /// @notice Set the implementation reference
    /// @param _implementationReference The implementation reference
    function setImplementationReference(address _implementationReference) public onlyRole(ADMIN_ROLE) {
        require(_implementationReference != address(0), ErrorsLib.ZeroAddress());

        address oldImplementationReference = implementationReference;
        implementationReference = _implementationReference;

        emit EventsLib.ImplementationReferenceSet(oldImplementationReference, _implementationReference);
    }
}
