// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import { ClaimIssuer } from "@onchain-id/solidity/contracts/ClaimIssuer.sol";
import { Identity } from "@onchain-id/solidity/contracts/Identity.sol";
import { IdFactory } from "@onchain-id/solidity/contracts/factory/IdFactory.sol";
import { KeyPurposes } from "@onchain-id/solidity/contracts/libraries/KeyPurposes.sol";
import { KeyTypes } from "@onchain-id/solidity/contracts/libraries/KeyTypes.sol";
import { IdentityProxy } from "@onchain-id/solidity/contracts/proxy/IdentityProxy.sol";
import { ImplementationAuthority } from "@onchain-id/solidity/contracts/proxy/ImplementationAuthority.sol";

import { CommonBase } from "forge-std/src/Base.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

// solhint-disable max-states-count
contract OnchainId is StdCheats, CommonBase {
    Identity public identity;
    IdentityProxy public identityProxy;
    ImplementationAuthority public implementationAuthority;
    IdFactory public idFactory;

    ClaimIssuer public claimIssuer;

    address public managementKey;

    address public alice;
    uint256 public alicePKey;
    Identity public aliceIdentity;

    address public bob;
    Identity public bobIdentity;

    address public charlie;
    Identity public charlieIdentity;

    Identity public tokenIdentity;
    address public tokenOwner;

    address public token = 0xdEE019486810C7C620f6098EEcacA0244b0fa3fB;

    constructor() {
        managementKey = makeAddr("managementKey");

        (alice, alicePKey) = makeAddrAndKey("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        tokenOwner = makeAddr("tokenOwner");

        deployFactoryFixture();
        deployIdentityFixture();
    }

    function deployFactoryFixture() internal {
        identity = new Identity(managementKey, true);
        implementationAuthority = new ImplementationAuthority(address(identity));
        idFactory = new IdFactory(address(implementationAuthority));

        identityProxy = new IdentityProxy(address(implementationAuthority), managementKey);
    }

    function deployIdentityFixture() internal {
        claimIssuer = new ClaimIssuer(msg.sender);
        claimIssuer.addKey(keccak256(abi.encode(msg.sender)), KeyPurposes.CLAIM_SIGNER, KeyTypes.ECDSA);

        aliceIdentity = Identity(idFactory.createIdentity(alice, "alice"));
        vm.startPrank(alice);
        aliceIdentity.addKey(keccak256(abi.encode(alice)), KeyPurposes.CLAIM_SIGNER, KeyTypes.ECDSA);
        aliceIdentity.addKey(keccak256(abi.encode(alice)), KeyPurposes.ACTION, KeyTypes.ECDSA);

        uint256 topic = 666;
        uint256 scheme = 1;
        bytes memory data = "0x0042";
        string memory uri = "https://example.com";
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            alicePKey,
            keccak256(abi.encode(address(aliceIdentity), topic, data))
        );
        bytes memory signature = abi.encodePacked(r, s, v);
        aliceIdentity.addClaim(topic, scheme, address(claimIssuer), signature, data, uri);
        vm.stopPrank();

        bobIdentity = Identity(idFactory.createIdentity(bob, "bob"));
        charlieIdentity = Identity(idFactory.createIdentity(charlie, "charlie"));

        tokenIdentity = Identity(idFactory.createTokenIdentity(token, tokenOwner, "tokenOwner"));
    }
}
