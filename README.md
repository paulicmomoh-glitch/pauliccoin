# PaulicCoin (PLIC) 🪙

A comprehensive fungible token implementation on the Stacks blockchain using Clarity smart contracts.

## PaulicBit (PBIT) — Clarinet contract added

A simple fungible token contract has been added under `contracts/paulicbit.clar` and registered in `Clarinet.toml` as `[contracts.paulicbit]`.

Quickstart:

```bash
clarinet check
clarinet console
```

In the Clarinet console REPL:

```clarity
(contract-call? .paulicbit initialize)
(contract-call? .paulicbit mint 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA u1000)
(contract-call? .paulicbit transfer 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA u250)
(contract-call? .paulicbit get-balance 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
```
## 📋 Overview

PaulicCoin (PLIC) is a fully-featured fungible token that implements standard token functionality including transfers, allowances, minting, and burning. Built with Clarity and designed for the Stacks ecosystem, it provides a robust foundation for DeFi applications and token-based projects.

### ✨ Key Features

- **Standard Token Operations**: Transfer, approve, and transfer-from functionality
- **Minting & Burning**: Controlled token supply management
- **Access Control**: Owner-only functions for privileged operations
- **Initialization Pattern**: Secure contract deployment and setup
- **Comprehensive Testing**: Full test coverage with edge cases
- **Gas Optimized**: Efficient Clarity code for minimal transaction costs

## 🛠 Technical Specifications

- **Token Name**: PaulicCoin
- **Symbol**: PLIC
- **Decimals**: 8
- **Initial Supply**: 1,000,000 PLIC (100,000,000,000,000 micro-tokens)
- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity

## 🚀 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v16 or higher)
- [Clarinet](https://docs.hiro.so/clarinet) (v3.7.0 or higher)
- [Git](https://git-scm.com/)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/pauliccoin.git
cd pauliccoin
```

2. Install dependencies:
```bash
npm install
```

3. Verify the setup:
```bash
clarinet check
```

### Development Setup

1. Start the local development environment:
```bash
clarinet console
```

2. Deploy and initialize the contract:
```clarity
(contract-deploy .pauliccoin (cat ./contracts/pauliccoin.clar))
(contract-call? .pauliccoin initialize)
```

## 📖 Smart Contract API

### Public Functions

#### `initialize()`
Initializes the contract and mints the total supply to the contract owner.
- **Access**: Contract owner only
- **Can only be called once**

#### `transfer(amount, recipient)`
Transfers tokens from the sender to a recipient.
- **Parameters**:
  - `amount` (uint): Amount to transfer (in micro-tokens)
  - `recipient` (principal): Recipient address
- **Returns**: `(ok true)` on success

#### `transfer-from(owner, recipient, amount)`
Transfers tokens on behalf of another address (requires allowance).
- **Parameters**:
  - `owner` (principal): Token owner address
  - `recipient` (principal): Recipient address
  - `amount` (uint): Amount to transfer
- **Returns**: `(ok true)` on success

#### `approve(spender, amount)`
Approves another address to spend tokens on your behalf.
- **Parameters**:
  - `spender` (principal): Address to approve
  - `amount` (uint): Maximum amount to approve
- **Returns**: `(ok true)` on success

#### `mint(amount, recipient)`
Mints new tokens to a recipient address.
- **Access**: Contract owner only
- **Parameters**:
  - `amount` (uint): Amount to mint
  - `recipient` (principal): Recipient address
- **Returns**: `(ok true)` on success

#### `burn(amount)`
Burns tokens from the sender's balance.
- **Parameters**:
  - `amount` (uint): Amount to burn
- **Returns**: `(ok true)` on success

### Read-Only Functions

#### `get-name()`
Returns the token name: "PaulicCoin"

#### `get-symbol()`
Returns the token symbol: "PLIC"

#### `get-decimals()`
Returns the token decimals: 8

#### `get-total-supply()`
Returns the maximum token supply

#### `get-tokens-in-circulation()`
Returns the current tokens in circulation

#### `get-balance(account)`
Returns the token balance of an account
- **Parameters**: `account` (principal)

#### `get-allowance(owner, spender)`
Returns the approved allowance between owner and spender
- **Parameters**: `owner` (principal), `spender` (principal)

#### `is-initialized()`
Returns whether the contract has been initialized

#### `get-contract-owner()`
Returns the contract owner address

## 🧪 Testing

The project includes comprehensive tests covering all functionality:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run specific test file
npm test -- pauliccoin.test.ts
```

### Test Coverage

- ✅ Contract initialization
- ✅ Token metadata retrieval
- ✅ Token transfers
- ✅ Allowance system
- ✅ Minting (owner only)
- ✅ Token burning
- ✅ Error conditions and edge cases
- ✅ Access control validation

## 🔧 Development Commands

```bash
# Check contract syntax
clarinet check

# Run local console
clarinet console

# Generate deployment plan
clarinet deployment generate --devnet

# Apply deployment
clarinet deployment apply --devnet
```

## 🚀 Deployment

### Devnet Deployment

1. Generate deployment plan:
```bash
clarinet deployment generate --devnet
```

2. Apply the deployment:
```bash
clarinet deployment apply --devnet
```

### Testnet/Mainnet Deployment

1. Configure your deployment in `settings/Testnet.toml` or `settings/Mainnet.toml`
2. Update the deployment plan
3. Deploy using Clarinet or your preferred deployment tool

## 📊 Token Economics

- **Initial Supply**: 1,000,000 PLIC
- **Decimals**: 8 (smallest unit: 0.00000001 PLIC)
- **Supply Control**: Owner can mint additional tokens
- **Deflationary**: Anyone can burn their own tokens
- **Transfer Fee**: None (only network fees apply)

## 🔒 Security Features

- **Initialization Guard**: Prevents multiple initialization
- **Owner-Only Functions**: Minting restricted to contract owner
- **Balance Checks**: Prevents transfers/burns exceeding balance
- **Allowance System**: Secure delegated spending
- **Input Validation**: All functions validate parameters

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`npm test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Maintain 100% test coverage
- Document all public functions
- Use descriptive commit messages
- Ensure contracts pass `clarinet check`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♀️ Support

If you have questions or need help:

- Open an issue on GitHub
- Check the [Clarity documentation](https://docs.stacks.co/clarity)
- Visit the [Stacks Discord](https://discord.gg/stacks)

## 🙏 Acknowledgments

- Stacks Foundation for the Clarity language
- Hiro for the excellent Clarinet development tools
- The Stacks community for ongoing support and feedback

---

**⚠️ Disclaimer**: This is a demonstration token contract. Please conduct thorough testing and audits before using in production environments.
