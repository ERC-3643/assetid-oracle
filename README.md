# AssetID Oracle

The AssetID Oracle is a smart contract that provides real-time price information for ERC3643 asset tokens in terms of a chosen payment token (e.g., USD stablecoin). It acts as a bridge between onchain asset identity data and external price feeds, enabling accurate and compliant pricing for subscriptions and redemptions.

## How It Works
- The oracle integrates with the ERC3643 asset's onchain identity contract, which stores the Net Asset Value (NAV) per share as a claim.
- It also connects to a Chainlink-compatible price oracle for the payment token (such as a stablecoin/USD feed).
- When queried, the AssetID Oracle retrieves the latest NAV per share from the identity contract and the current payment token price from the external oracle.
- It then computes the up-to-date price of the asset token in the payment token, scaling values as needed for decimals and compliance.
- The contract implements the `AggregatorV3Interface`, making it compatible with Chainlink-style consumers and tooling.

## Role in the System
- Ensures that subscriptions and redemptions use accurate, up-to-date asset pricing.
- Enables compliance by sourcing NAV directly from the asset's onchain identity, which can be updated by authorized parties.
- Supports flexible integration with different payment tokens and price feeds.

This design allows the DINO Primary system to offer transparent, auditable, and compliant pricing for tokenized securities, leveraging both onchain and offchain data sources.

### Installation

1. **Install dependencies**
   ```bash
   # Install Node.js dependencies, Husky and Solidity libraries
   npm install
   ```

2. **Build the project**
   ```bash
   npm run build
   ```

## 🛠️ Development Commands

### Project Commands
```bash
# Build contracts
npm run build

# Run tests
npm run test

# Run tests with coverage
npm run coverage

# Clean build artifacts
npm run clean
```

### Code Quality Commands
```bash
# Check code formatting and linting
npm run lint

# Fix formatting issues automatically
npm run lint:fix

# Generate coverage reports
npm run coverage:report
```
