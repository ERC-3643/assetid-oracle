// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

contract Counter {
    uint256 private _number;

    function setNumber(uint256 newNumber) public {
        _number = newNumber;
    }

    function increment() public {
        _number++;
    }

    function number() public view returns (uint256) {
        return _number;
    }
}
