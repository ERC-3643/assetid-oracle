// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC3643Compliance } from "@erc3643org/erc-3643/contracts/ERC-3643/IERC3643Compliance.sol";
import { IERC3643IdentityRegistry } from "@erc3643org/erc-3643/contracts/ERC-3643/IERC3643IdentityRegistry.sol";

contract ERC3643Stub is ERC20, Ownable {
    address public immutable identityRegistryAddress;
    address public immutable complianceAddress;
    address public immutable identity;

    constructor(
        string memory name,
        string memory symbol,
        address _identityRegistry,
        address _compliance,
        address _identity
    ) ERC20(name, symbol) Ownable(msg.sender) {
        identityRegistryAddress = _identityRegistry;
        complianceAddress = _compliance;
        identity = _identity;
    }

    function identityRegistry() external view returns (IERC3643IdentityRegistry) {
        return IERC3643IdentityRegistry(identityRegistryAddress);
    }

    function compliance() external view returns (IERC3643Compliance) {
        return IERC3643Compliance(complianceAddress);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }

    function onchainID() external view returns (address) {
        return identity;
    }

    function addAgent(address agent) external {
        // No-op
    }
}
