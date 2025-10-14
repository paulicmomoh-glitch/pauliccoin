# PaulicCoin Deployment and Initialization Guide

This guide walks you through deploying and initializing the PaulicCoin smart contract.

## Quick Deployment (Devnet)

### 1. Deploy the Contract
```bash
clarinet deployment apply --devnet
```

### 2. Initialize the Contract (Console)
```bash
clarinet console
```

In the console, run:
```clarity
;; Deploy contract (if not already deployed)
(contract-deploy .pauliccoin (cat ./contracts/pauliccoin.clar))

;; Initialize the contract
(contract-call? .pauliccoin initialize)

;; Check initialization status
(contract-call? .pauliccoin is-initialized)

;; Check deployer balance
(contract-call? .pauliccoin get-balance tx-sender)

;; Check total supply
(contract-call? .pauliccoin get-total-supply)
```

## Manual Deployment Steps

### 1. Deploy to Devnet
```bash
# Generate deployment plan
clarinet deployment generate --devnet

# Review the plan (optional)
cat deployments/default.devnet-plan.yaml

# Apply deployment
clarinet deployment apply --devnet
```

### 2. Initialize Contract
After deployment, the contract needs to be initialized to mint the initial supply:

```clarity
(contract-call? .pauliccoin initialize)
```

### 3. Verify Deployment
```clarity
;; Check contract metadata
(contract-call? .pauliccoin get-name)
(contract-call? .pauliccoin get-symbol)
(contract-call? .pauliccoin get-decimals)
(contract-call? .pauliccoin get-total-supply)

;; Check initialization and owner
(contract-call? .pauliccoin is-initialized)
(contract-call? .pauliccoin get-contract-owner)
```

## Example Usage

### Transfer Tokens
```clarity
;; Transfer 10 PLIC (10 * 10^8 micro-tokens) to another address
(contract-call? .pauliccoin transfer u1000000000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Approve and Transfer-From
```clarity
;; Approve spender for 5 PLIC
(contract-call? .pauliccoin approve 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u500000000)

;; Spender transfers from owner to recipient (as spender)
(contract-call? .pauliccoin transfer-from tx-sender 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u500000000)
```

### Mint Additional Tokens (Owner Only)
```clarity
;; Mint 1000 PLIC to recipient
(contract-call? .pauliccoin mint u100000000000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Burn Tokens
```clarity
;; Burn 100 PLIC from own balance
(contract-call? .pauliccoin burn u10000000000)
```

## Testnet/Mainnet Deployment

For testnet or mainnet deployment:

1. Update settings in `settings/Testnet.toml` or `settings/Mainnet.toml`
2. Generate deployment plan for target network
3. Apply deployment with appropriate network flag
4. Initialize the contract

```bash
# For Testnet
clarinet deployment generate --testnet
clarinet deployment apply --testnet

# For Mainnet  
clarinet deployment generate --mainnet
clarinet deployment apply --mainnet
```

## Important Notes

- The contract MUST be initialized after deployment to be functional
- Only the contract deployer can initialize the contract
- Initialization can only happen once
- The deployer receives the initial token supply upon initialization
- All amounts use micro-tokens (8 decimal places)