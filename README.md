# ERC3643 Template

A comprehensive Solidity development template for ERC3643 related projects, featuring modern development tools and best practices.

## 🏗️ Architecture Overview

This template provides a robust foundation for Solidity smart contract development with the following key components:

### Core Development Framework
- **Foundry** - Fast, portable and modular toolkit for Ethereum application development
- **Forge** - Testing framework for Foundry with built-in fuzzing and invariant testing
- **Hardhat** - Ethereum development environment with TypeScript support and comprehensive testing tools

### Code Quality & Linting
- **Solhint** - Solidity linting rules with OpenZeppelin best practices
- **Prettier** - Code formatting with Solidity plugin support

### Git Hooks & Workflow
- **Husky** - Git hooks for automated quality checks
- **Pre-commit Hooks** - Automated linting and coverage checks
- **Commitlint** - With gitmoji commit message validation

## 🚀 Getting Started

### Prerequisites
- [Foundry](https://getfoundry.sh/) - Install Foundry toolkit
- [Node.js](https://nodejs.org/) (v18+) - For JavaScript/TypeScript tooling and Hardhat
- [npm](https://npmjs.com/) - For packages management

### Installation

1. **Clone the template**
   ```bash
   git clone <repository-url>
   cd contracts-template
   ```

2. **Install dependencies**
   ```bash
   # Install Node.js dependencies, Husky and Solidity libraries
   npm install
   ```

3. **Build the project**
   ```bash
   npm run build
   ```

## 🛠️ Development Commands

### Project Commands
```bash
# Build contracts (both Foundry and Hardhat)
npm run build:forge    # Build with Foundry
npm run build:hardhat  # Build with Hardhat

# Run tests
npm run test:forge     # Run Foundry tests
npm run test:hardhat   # Run Hardhat tests

# Run tests with coverage
npm run coverage:forge     # Coverage with Foundry
npm run coverage:hardhat   # Coverage with Hardhat

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
npm run coverage:forge:report     # Foundry coverage report
npm run coverage:hardhat:report   # Hardhat coverage report
```

## 📁 Project Structure

```
template/
├── contracts/          # Smart contract source files
├── test/              # Test files (Foundry .sol and Hardhat .ts)
├── scripts/           # Deployment and utility scripts
├── .husky/            # Git hooks configuration
├── .github/           # GitHub workflows and scripts
├── .prettierrc        # Prettier formatting configuration
├── foundry.toml       # Foundry configuration
├── hardhat.config.ts  # Hardhat configuration
├── solhint.config.js  # Solhint linting rules
├── tsconfig.json      # TypeScript configuration
└── package.json       # Node.js dependencies and scripts
```

## 🔧 Configuration

### Foundry Configuration (`foundry.toml`)
- Solidity compiler version: 0.8.30
- Optimizer enabled with 200 runs

### Hardhat Configuration (`hardhat.config.ts`)
- Solidity compiler version: 0.8.30 with Cancun EVM
- Optimizer enabled with 200 runs
- Gas reporting enabled for cost analysis

### Solhint Configuration (`solhint.config.js`)
- OpenZeppelin best practices integration
- Custom project-specific rules:
  - Interface naming conventions (`I` prefix)
  - Private variable naming (`_` prefix)
  - State variable visibility requirements
  - Function naming conventions

### Prettier Configuration (`.prettierrc`)
- 120 character line width
- Single quotes for JavaScript, double quotes for Solidity
- Trailing commas enabled
- Solidity plugin integration

## 🎯 Key Features

### Dual Framework Support
This template provides both **Foundry** and **Hardhat** development environments:

- **Foundry**: Ideal for Solidity-focused development with fast compilation, advanced testing features (fuzzing, invariant testing), and gas optimization
- **Hardhat**: Perfect for TypeScript integration, complex deployment scripts, and projects requiring extensive JavaScript/TypeScript tooling

### Automated Quality Assurance
- **Pre-commit Hooks**: Automatic linting and coverage checks before commits
- **Commit Message Validation**: Enforces gitmoji commit format
- **Continuous Integration**: Automated testing and quality checks
- **Dual Coverage**: Both Foundry and Hardhat coverage reporting for comprehensive analysis

## 📚 Dependencies

### Solidity Dependencies
- `forge-std`: Foundry standard library
- `onchain-id`: Onchain identity management
- `erc-3643`: ERC3643 token standard implementation
- `openzeppelin`: Secure smart contract libraries

### Development Dependencies
- `hardhat`: Ethereum development environment
- `@nomicfoundation/hardhat-toolbox`: Hardhat plugins and tools
- `@nomicfoundation/hardhat-ethers`: Ethers.js integration
- `@typechain/hardhat`: TypeScript type generation
- `ethers`: Ethereum library
- `typescript`: TypeScript support
- `husky`: Git hooks management
- `prettier`: Code formatting
- `solhint`: Solidity linting
- `commitlint`: Commit message validation


