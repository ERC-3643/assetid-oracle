// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

contract IdentityRegistryStub {
    mapping(address => bool) verified;

    function isVerified(address _userAddress) external view returns (bool) {
        return verified[_userAddress];
    }

    function setVerified(address _userAddress, bool _verified) external {
        verified[_userAddress] = _verified;
    }
}
