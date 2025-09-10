// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

import { IIdentity } from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

contract IdentityStub is IIdentity {
    address private _issuer;

    uint256 private _value;
    uint256 private _decimals;
    uint256 private _timestamp;

    bool private _invalidTopic;

    constructor() {
        _issuer = msg.sender;
    }

    function setValue(uint256 value) external {
        _value = value;
    }

    function setDecimals(uint256 decimals) external {
        _decimals = decimals;
    }

    function setTimestamp(uint256 timestamp) external {
        _timestamp = timestamp;
    }

    function setTopicInvalidStatus(bool invalidTopic) external {
        _invalidTopic = invalidTopic;
    }

    function getClaimIdsByTopic(uint256 topic) external view returns (bytes32[] memory) {
        if (topic != 1_000_003 || _invalidTopic) {
            return new bytes32[](0);
        }

        return new bytes32[](1);
    }

    function getClaim(
        bytes32 /* claimId */
    )
        external
        view
        returns (
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {
        topic = 1_000_003;
        scheme = 0;
        issuer = _issuer;
        signature = new bytes(0);
        data = abi.encode(_value, _decimals, _timestamp);
        uri = "";
    }

    // ----- Unused functions -----

    function addClaim(
        uint256 /* topic */,
        uint256 /* scheme */,
        address /* issuer */,
        bytes memory /* signature */,
        bytes memory /* data */,
        string memory /* uri */
    ) external pure override returns (bytes32 claimRequestId) {
        return bytes32(0);
    }

    function addKey(bytes32, /* _key */ uint256, /* _purpose */ uint256 /* _keyType */) external pure returns (bool) {
        return false;
    }

    function approve(uint256, /* _id */ bool /* _approve */) external pure returns (bool) {
        return false;
    }

    function execute(
        address,
        /* _to */
        uint256,
        /* _value */
        bytes calldata /* _data */
    ) external payable returns (uint256) {
        return 0;
    }

    function getKey(
        bytes32 /* _key */
    ) external pure returns (uint256[] memory purposes, uint256 keyType, bytes32 key) {
        return (new uint256[](0), 0, bytes32(0));
    }

    function getKeyPurposes(bytes32 /* _key */) external pure returns (uint256[] memory _purposes) {
        return new uint256[](0);
    }

    function getKeysByPurpose(uint256 /* _purpose */) external pure returns (bytes32[] memory keys) {
        return new bytes32[](0);
    }

    function keyHasPurpose(bytes32, /* _key */ uint256 /* _purpose */) external pure returns (bool exists) {
        return false;
    }

    function removeClaim(bytes32 /* _claimId */) external pure returns (bool success) {
        return false;
    }

    function removeKey(bytes32, /* _key */ uint256 /* _purpose */) external pure returns (bool success) {
        return false;
    }

    function isClaimValid(
        IIdentity /* _identity */,
        uint256 /* claimTopic */,
        bytes calldata /* sig */,
        bytes calldata /* data */
    ) external pure returns (bool) {
        return false;
    }
}
