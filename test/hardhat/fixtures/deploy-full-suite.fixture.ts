import { ethers } from 'hardhat';
import { Contract, Signer } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import OnchainID from '@onchain-id/solidity';
import ERC3643 from '@erc3643org/erc-3643';

export async function deployIdentityProxy(
  implementationAuthority: Contract['target'],
  managementKey: string,
  signer: Signer,
) {
  const identity = await new ethers.ContractFactory(
    OnchainID.contracts.IdentityProxy.abi,
    OnchainID.contracts.IdentityProxy.bytecode,
    signer,
  ).deploy(implementationAuthority, managementKey);
  return ethers.getContractAt(OnchainID.contracts.Identity.abi, identity.target, signer);
}

export async function deployClaimIssuer(initialManagementKey: string, signer: Signer) {
  const claimIssuer = await new ethers.ContractFactory(
    OnchainID.contracts.ClaimIssuer.abi,
    OnchainID.contracts.ClaimIssuer.bytecode,
    signer,
  ).deploy(initialManagementKey);
  return ethers.getContractAt(OnchainID.contracts.ClaimIssuer.abi, claimIssuer.target, signer);
}

export async function deployFullSuiteFixture() {
  const [
    deployer,
    tokenIssuer,
    tokenAgent,
    tokenAdmin,
    claimIssuer,
    aliceWallet,
    bobWallet,
    charlieWallet,
    davidWallet,
    anotherWallet,
  ] = await ethers.getSigners();
  const claimIssuerSigningKey = ethers.Wallet.createRandom();
  const aliceActionKey = ethers.Wallet.createRandom();
  // Deploy implementations
  const claimTopicsRegistryImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.ClaimTopicsRegistry.abi as any,
    ERC3643.contracts.ClaimTopicsRegistry.bytecode,
    deployer,
  ).deploy();
  const trustedIssuersRegistryImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.TrustedIssuersRegistry.abi as any,
    ERC3643.contracts.TrustedIssuersRegistry.bytecode,
    deployer,
  ).deploy();
  const identityRegistryStorageImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.IdentityRegistryStorage.abi as any,
    ERC3643.contracts.IdentityRegistryStorage.bytecode,
    deployer,
  ).deploy();
  const identityRegistryImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.IdentityRegistry.abi as any,
    ERC3643.contracts.IdentityRegistry.bytecode,
    deployer,
  ).deploy();
  const modularComplianceImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.ModularCompliance.abi as any,
    ERC3643.contracts.ModularCompliance.bytecode,
    deployer,
  ).deploy();
  const tokenImplementation = await new ethers.ContractFactory(
    ERC3643.contracts.Token.abi as any,
    ERC3643.contracts.Token.bytecode,
    deployer,
  ).deploy();
  const identityImplementation = await new ethers.ContractFactory(
    OnchainID.contracts.Identity.abi,
    OnchainID.contracts.Identity.bytecode,
    deployer,
  ).deploy(deployer.address, true);
  const identityImplementationAuthority = await new ethers.ContractFactory(
    OnchainID.contracts.ImplementationAuthority.abi,
    OnchainID.contracts.ImplementationAuthority.bytecode,
    deployer,
  ).deploy(identityImplementation.target);
  const identityFactory = await new ethers.ContractFactory(
    OnchainID.contracts.Factory.abi,
    OnchainID.contracts.Factory.bytecode,
    deployer,
  ).deploy(identityImplementationAuthority.target);
  const trexImplementationAuthority = await new ethers.ContractFactory(
    ERC3643.contracts.TREXImplementationAuthority.abi as any,
    ERC3643.contracts.TREXImplementationAuthority.bytecode,
    deployer,
  ).deploy(true, ethers.ZeroAddress, ethers.ZeroAddress);
  const versionStruct = {
    major: 4,
    minor: 0,
    patch: 0,
  };
  const contractsStruct = {
    tokenImplementation: tokenImplementation.target,
    ctrImplementation: claimTopicsRegistryImplementation.target,
    irImplementation: identityRegistryImplementation.target,
    irsImplementation: identityRegistryStorageImplementation.target,
    tirImplementation: trustedIssuersRegistryImplementation.target,
    mcImplementation: modularComplianceImplementation.target,
  };
  await trexImplementationAuthority.connect(deployer).addAndUseTREXVersion(versionStruct, contractsStruct);

  const trexFactory = await new ethers.ContractFactory(
    ERC3643.contracts.TREXFactory.abi as any,
    ERC3643.contracts.TREXFactory.bytecode,
    deployer,
  ).deploy(trexImplementationAuthority.target, identityFactory.target);
  await (identityFactory.connect(deployer) as IIdFactory).addTokenFactory(trexFactory.target);

  const claimTopicsRegistry = await new ethers.ContractFactory(
    ERC3643.contracts.ClaimTopicsRegistryProxy.abi as any,
    ERC3643.contracts.ClaimTopicsRegistryProxy.bytecode,
    deployer,
  )
    .deploy(trexImplementationAuthority.target)
    .then(async proxy => ethers.getContractAt(ERC3643.contracts.ClaimTopicsRegistry.abi as any, proxy.target));
  const trustedIssuersRegistry = await new ethers.ContractFactory(
    ERC3643.contracts.TrustedIssuersRegistryProxy.abi as any,
    ERC3643.contracts.TrustedIssuersRegistryProxy.bytecode,
    deployer,
  )
    .deploy(trexImplementationAuthority.target)
    .then(async proxy => ethers.getContractAt(ERC3643.contracts.TrustedIssuersRegistry.abi as any, proxy.target));
  const identityRegistryStorage = await new ethers.ContractFactory(
    ERC3643.contracts.IdentityRegistryStorageProxy.abi as any,
    ERC3643.contracts.IdentityRegistryStorageProxy.bytecode,
    deployer,
  )
    .deploy(trexImplementationAuthority.target)
    .then(async proxy => ethers.getContractAt(ERC3643.contracts.IdentityRegistryStorage.abi as any, proxy.target));

  const identityRegistry = await new ethers.ContractFactory(
    ERC3643.contracts.IdentityRegistryProxy.abi as any,
    ERC3643.contracts.IdentityRegistryProxy.bytecode,
    deployer,
  )
    .deploy(
      trexImplementationAuthority.target,
      trustedIssuersRegistry.target,
      claimTopicsRegistry.target,
      identityRegistryStorage.target,
    )
    .then(async proxy => ethers.getContractAt(ERC3643.contracts.IdentityRegistry.abi as any, proxy.target));

  const tokenOID = await deployIdentityProxy(identityImplementationAuthority.target, tokenIssuer.address, deployer);
  const tokenName = 'TREXDINO';
  const tokenSymbol = 'TREX';
  const tokenDecimals = 0n;
  const token = await new ethers.ContractFactory(
    ERC3643.contracts.TokenProxy.abi as any,
    ERC3643.contracts.TokenProxy.bytecode,
    deployer,
  )
    .deploy(
      trexImplementationAuthority.target,
      identityRegistry.target,
      modularComplianceImplementation.target,
      tokenName,
      tokenSymbol,
      tokenDecimals,
      tokenOID.target,
    )
    .then(async proxy => ethers.getContractAt(ERC3643.contracts.Token.abi as any, proxy.target));
  await identityRegistryStorage.connect(deployer).bindIdentityRegistry(identityRegistry.target);

  await token.connect(deployer).addAgent(tokenAgent.address);

  const claimTopics = [ethers.keccak256(ethers.toUtf8Bytes('CLAIM_TOPIC'))];
  await claimTopicsRegistry.connect(deployer).addClaimTopic(claimTopics[0]);

  const claimIssuerContract = await deployClaimIssuer(claimIssuer.address, claimIssuer);
  await claimIssuerContract
    .connect(claimIssuer)
    .addKey(
      ethers.keccak256(ethers.AbiCoder.defaultAbiCoder().encode(['address'], [claimIssuerSigningKey.address])),
      3,
      1,
    );

  await trustedIssuersRegistry.connect(deployer).addTrustedIssuer(claimIssuerContract.target, claimTopics);

  const aliceIdentity = await deployIdentityProxy(
    identityImplementationAuthority.target,
    aliceWallet.address,
    deployer,
  );
  await aliceIdentity
    .connect(aliceWallet)
    .addKey(ethers.keccak256(ethers.AbiCoder.defaultAbiCoder().encode(['address'], [aliceActionKey.address])), 2, 1);
  const bobIdentity = await deployIdentityProxy(identityImplementationAuthority.target, bobWallet.address, deployer);
  const charlieIdentity = await deployIdentityProxy(
    identityImplementationAuthority.target,
    charlieWallet.address,
    deployer,
  );

  await identityRegistry.connect(deployer).addAgent(tokenAgent.address);
  await identityRegistry.connect(deployer).addAgent(token.target);

  await identityRegistry
    .connect(tokenAgent)
    .batchRegisterIdentity(
      [aliceWallet.address, bobWallet.address],
      [aliceIdentity.target, bobIdentity.target],
      [42, 666],
    );

  const claimForAlice = {
    data: ethers.hexlify(ethers.toUtf8Bytes('Some claim public data.')),
    issuer: claimIssuerContract.target,
    topic: claimTopics[0],
    scheme: 1,
    identity: aliceIdentity.target,
    signature: '',
  };
  claimForAlice.signature = await claimIssuerSigningKey.signMessage(
    ethers.getBytes(
      ethers.keccak256(
        ethers.AbiCoder.defaultAbiCoder().encode(
          ['address', 'uint256', 'bytes'],
          [claimForAlice.identity, claimForAlice.topic, claimForAlice.data],
        ),
      ),
    ),
  );

  await aliceIdentity
    .connect(aliceWallet)
    .addClaim(
      claimForAlice.topic,
      claimForAlice.scheme,
      claimForAlice.issuer,
      claimForAlice.signature,
      claimForAlice.data,
      '',
    );

  const claimForBob = {
    data: ethers.hexlify(ethers.toUtf8Bytes('Some claim public data.')),
    issuer: claimIssuerContract.target,
    topic: claimTopics[0],
    scheme: 1,
    identity: bobIdentity.target,
    signature: '',
  };
  claimForBob.signature = await claimIssuerSigningKey.signMessage(
    ethers.getBytes(
      ethers.keccak256(
        ethers.AbiCoder.defaultAbiCoder().encode(
          ['address', 'uint256', 'bytes'],
          [claimForBob.identity, claimForBob.topic, claimForBob.data],
        ),
      ),
    ),
  );

  await bobIdentity
    .connect(bobWallet)
    .addClaim(claimForBob.topic, claimForBob.scheme, claimForBob.issuer, claimForBob.signature, claimForBob.data, '');

  await token.connect(tokenAgent).mint(aliceWallet.address, 1000);
  await token.connect(tokenAgent).mint(bobWallet.address, 500);

  await token.connect(tokenAgent).unpause();

  return {
    accounts: {
      deployer,
      tokenIssuer,
      tokenAgent,
      tokenAdmin,
      claimIssuer,
      claimIssuerSigningKey,
      aliceActionKey,
      aliceWallet,
      bobWallet,
      charlieWallet,
      davidWallet,
      anotherWallet,
    },
    identities: {
      aliceIdentity,
      bobIdentity,
      charlieIdentity,
    },
    suite: {
      claimIssuerContract,
      claimTopicsRegistry,
      trustedIssuersRegistry,
      identityRegistryStorage,
      identityRegistry,
      tokenOID,
      token,
    },
    authorities: {
      trexImplementationAuthority,
      identityImplementationAuthority,
    },
    factories: {
      trexFactory,
      identityFactory,
    },
    implementations: {
      identityImplementation,
      claimTopicsRegistryImplementation,
      trustedIssuersRegistryImplementation,
      identityRegistryStorageImplementation,
      identityRegistryImplementation,
      modularComplianceImplementation,
      tokenImplementation,
    },
  };
}

export async function deploySuiteWithModularCompliancesFixture() {
  const context = await loadFixture(deployFullSuiteFixture);
  const complianceProxy = await ethers.deployContract('ModularComplianceProxy', [
    context.authorities.trexImplementationAuthority.target,
  ]);
  const compliance = await ethers.getContractAt('ModularCompliance', complianceProxy.target);

  const complianceBeta = await ethers.deployContract('ModularCompliance');
  await complianceBeta.init();

  await context.suite.token.connect(context.accounts.deployer).setCompliance(compliance.target);

  return {
    ...context,
    suite: {
      ...context.suite,
      compliance,
      complianceBeta,
    },
  };
}

export async function deploySuiteWithModuleComplianceBoundToWallet() {
  const context = await loadFixture(deployFullSuiteFixture);

  const compliance = await ethers.deployContract('ModularCompliance');
  await compliance.init();

  const complianceModuleA = await ethers.deployContract('CountryAllowModule');
  await compliance.addModule(complianceModuleA.target);
  const complianceModuleB = await ethers.deployContract('CountryAllowModule');
  await compliance.addModule(complianceModuleB.target);

  await compliance.bindToken(context.accounts.charlieWallet.address);

  return {
    ...context,
    suite: {
      ...context.suite,
      compliance,
      complianceModuleA,
      complianceModuleB,
    },
  };
}
