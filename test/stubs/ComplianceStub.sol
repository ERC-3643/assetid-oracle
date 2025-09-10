// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

contract ComplianceStub {
    mapping(address from => mapping(address to => bool canTransfer)) transfers;

    function canTransfer(address _from, address _to, uint256 /*_amount */) external view returns (bool) {
        return transfers[_from][_to];
    }

    function setCanTransfer(address _from, address _to, bool _canTransfer) external {
        transfers[_from][_to] = _canTransfer;
    }
}
