// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import { ModularCompliance } from "@erc3643org/erc-3643/contracts/compliance/modular/ModularCompliance.sol";

import { TREXFactory } from "@erc3643org/erc-3643/contracts/factory/TREXFactory.sol";
import { ClaimTopicsRegistryProxy } from "@erc3643org/erc-3643/contracts/proxy/ClaimTopicsRegistryProxy.sol";
import { IdentityRegistryProxy } from "@erc3643org/erc-3643/contracts/proxy/IdentityRegistryProxy.sol";
import { IdentityRegistryStorageProxy } from "@erc3643org/erc-3643/contracts/proxy/IdentityRegistryStorageProxy.sol";
import { ModularComplianceProxy } from "@erc3643org/erc-3643/contracts/proxy/ModularComplianceProxy.sol";

import { TokenProxy } from "@erc3643org/erc-3643/contracts/proxy/TokenProxy.sol";
import { TrustedIssuersRegistryProxy } from "@erc3643org/erc-3643/contracts/proxy/TrustedIssuersRegistryProxy.sol";
import {
    ITREXImplementationAuthority,
    TREXImplementationAuthority
} from "@erc3643org/erc-3643/contracts/proxy/authority/TREXImplementationAuthority.sol";
import { ClaimTopicsRegistry } from "@erc3643org/erc-3643/contracts/registry/implementation/ClaimTopicsRegistry.sol";
import { IdentityRegistry } from "@erc3643org/erc-3643/contracts/registry/implementation/IdentityRegistry.sol";
import { IdentityRegistryStorage } from "@erc3643org/erc-3643/contracts/registry/implementation/IdentityRegistryStorage.sol";
import { TrustedIssuersRegistry } from "@erc3643org/erc-3643/contracts/registry/implementation/TrustedIssuersRegistry.sol";
import { Token } from "@erc3643org/erc-3643/contracts/token/Token.sol";

import { OnchainId } from "./OnchainId.sol";
import { Identity } from "@onchain-id/solidity/contracts/Identity.sol";

import { KeyPurposes } from "@onchain-id/solidity/contracts/libraries/KeyPurposes.sol";
import { KeyTypes } from "@onchain-id/solidity/contracts/libraries/KeyTypes.sol";
import { IdentityProxy } from "@onchain-id/solidity/contracts/proxy/IdentityProxy.sol";

import { CommonBase } from "forge-std/src/Base.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

// solhint-disable max-states-count
contract Suite is StdCheats, CommonBase {
    OnchainId public onchainId;

    ClaimTopicsRegistry public claimTopicsRegistryImplementation;
    ClaimTopicsRegistry public claimTopicsRegistry;

    TrustedIssuersRegistry public trustedIssuersRegistryImplementation;
    TrustedIssuersRegistry public trustedIssuersRegistry;

    IdentityRegistryStorage public identityRegistryStorageImplementation;
    IdentityRegistryStorage public identityRegistryStorage;

    IdentityRegistry public identityRegistryImplementation;
    IdentityRegistry public identityRegistry;

    ModularCompliance public modularComplianceImplementation;
    ModularComplianceProxy public modularCompliance;

    Token public tokenImplementation;
    TREXImplementationAuthority public trexImplementationAuthority;
    TREXFactory public trexFactory;

    address public tokenIssuer;
    address public tokenAgent;
    address public claimIssuerSigninKey;

    Identity public tokenOID;
    Token public token;

    constructor() {
        onchainId = new OnchainId();

        tokenIssuer = makeAddr("tokenIssuer");
        tokenAgent = makeAddr("tokenAgent");
        claimIssuerSigninKey = makeAddr("claimIssuerSigninKey");
    }

    function deploySuite() public {
        claimTopicsRegistryImplementation = new ClaimTopicsRegistry();
        trustedIssuersRegistryImplementation = new TrustedIssuersRegistry();
        identityRegistryStorageImplementation = new IdentityRegistryStorage();
        identityRegistryImplementation = new IdentityRegistry();
        modularComplianceImplementation = new ModularCompliance();
        tokenImplementation = new Token();

        trexImplementationAuthority = new TREXImplementationAuthority(true, address(0), address(0));
        trexImplementationAuthority.addAndUseTREXVersion(
            ITREXImplementationAuthority.Version({ major: 4, minor: 0, patch: 0 }),
            ITREXImplementationAuthority.TREXContracts({
                tokenImplementation: address(tokenImplementation),
                ctrImplementation: address(claimTopicsRegistryImplementation),
                irImplementation: address(identityRegistryImplementation),
                irsImplementation: address(identityRegistryStorageImplementation),
                tirImplementation: address(trustedIssuersRegistryImplementation),
                mcImplementation: address(modularComplianceImplementation)
            })
        );

        trexFactory = new TREXFactory(address(trexImplementationAuthority), address(onchainId.idFactory()));
        onchainId.idFactory().addTokenFactory(address(trexFactory));

        claimTopicsRegistry = ClaimTopicsRegistry(
            address(new ClaimTopicsRegistryProxy(address(trexImplementationAuthority)))
        );
        trustedIssuersRegistry = TrustedIssuersRegistry(
            address(new TrustedIssuersRegistryProxy(address(trexImplementationAuthority)))
        );
        identityRegistryStorage = IdentityRegistryStorage(
            address(new IdentityRegistryStorageProxy(address(trexImplementationAuthority)))
        );
        modularCompliance = new ModularComplianceProxy(address(trexImplementationAuthority));
        identityRegistry = IdentityRegistry(
            address(
                new IdentityRegistryProxy(
                    address(trexImplementationAuthority),
                    address(trustedIssuersRegistry),
                    address(claimTopicsRegistry),
                    address(identityRegistryStorage)
                )
            )
        );

        tokenOID = Identity(address(new IdentityProxy(address(trexImplementationAuthority), tokenIssuer)));
        token = Token(
            address(
                new TokenProxy(
                    address(trexImplementationAuthority),
                    address(identityRegistry),
                    address(modularCompliance),
                    "TREXDINO",
                    "TREX",
                    0,
                    address(tokenOID)
                )
            )
        );
        identityRegistryStorage.bindIdentityRegistry(address(identityRegistry));
        token.addAgent(tokenAgent);

        uint256[] memory claimTopics = new uint256[](1);
        claimTopics[0] = uint256(keccak256(abi.encode("CLAIM_TOPIC")));

        claimTopicsRegistry.addClaimTopic(claimTopics[0]);
        onchainId.claimIssuer().addKey(
            keccak256(abi.encode(claimIssuerSigninKey)),
            KeyPurposes.CLAIM_SIGNER,
            KeyTypes.ECDSA
        );
        trustedIssuersRegistry.addTrustedIssuer(onchainId.claimIssuer(), claimTopics);

        identityRegistry.addAgent(tokenAgent);
        identityRegistry.addAgent(address(token));
        identityRegistry.registerIdentity(onchainId.alice(), onchainId.aliceIdentity(), 42);
        identityRegistry.registerIdentity(onchainId.bob(), onchainId.bobIdentity(), 666);

        // TODO: claim for Bob

        vm.startPrank(tokenAgent);
        token.mint(onchainId.alice(), 1000);
        token.mint(onchainId.bob(), 500);
        token.unpause();
        vm.stopPrank();
    }
}
