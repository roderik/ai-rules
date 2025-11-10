# Foundry Command Reference

## Project Setup

### Initialize New Project

```bash
# Create new Foundry project
forge init my-project
cd my-project

# Initialize in existing directory
forge init --force

# Initialize with template
forge init --template https://github.com/owner/template
```

### Project Structure

```
my-project/
├── foundry.toml          # Configuration
├── src/                  # Contract sources
├── test/                 # Test files
├── script/               # Deployment scripts
└── lib/                  # Dependencies
```

## Dependency Management

### Install Dependencies

```bash
# Install from GitHub
forge install OpenZeppelin/openzeppelin-contracts

# Install specific version
forge install OpenZeppelin/openzeppelin-contracts@v4.9.0

# Install with alias
forge install openzeppelin=OpenZeppelin/openzeppelin-contracts

# Update dependencies
forge update

# Remove dependency
forge remove openzeppelin-contracts
```

### Remappings

```bash
# Generate remappings
forge remappings > remappings.txt

# Example remappings.txt:
@openzeppelin/=lib/openzeppelin-contracts/
forge-std/=lib/forge-std/src/
```

## Building

### Compile Contracts

```bash
# Build all contracts
forge build

# Build with optimizer
forge build --optimize --optimizer-runs 200

# Build specific contract
forge build --contracts src/MyContract.sol

# Force rebuild
forge build --force

# Show compilation sizes
forge build --sizes
```

## Testing

### Run Tests

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test test_Transfer

# Run tests in specific contract
forge test --match-contract MyContractTest

# Run tests matching path
forge test --match-path test/unit/*

# Run with verbosity levels
forge test -v        # Show test results
forge test -vv       # Show console.log
forge test -vvv      # Show stack traces for failures
forge test -vvvv     # Show stack traces for all tests + setup
forge test -vvvvv    # Show full traces + setup

# Run specific number of fuzz runs
forge test --fuzz-runs 10000

# Run with gas reporting
forge test --gas-report

# Generate coverage report
forge coverage

# Run on fork
forge test --fork-url $MAINNET_RPC_URL

# Fork at specific block
forge test --fork-url $MAINNET_RPC_URL --fork-block-number 18000000
```

### Snapshot Testing

```bash
# Create gas snapshots
forge snapshot

# Compare with existing snapshot
forge snapshot --diff

# Check snapshot
forge snapshot --check
```

## Contract Interaction

### Cast Commands

```bash
# Call view function
cast call $CONTRACT "balanceOf(address)(uint256)" $ADDRESS

# Send transaction
cast send $CONTRACT "transfer(address,uint256)" $TO $AMOUNT --private-key $PK

# Get transaction receipt
cast receipt $TX_HASH

# Get block info
cast block latest

# Get account balance
cast balance $ADDRESS

# Get account nonce
cast nonce $ADDRESS

# Estimate gas
cast estimate $CONTRACT "mint(uint256)" 100

# Decode transaction data
cast 4byte-decode $CALLDATA

# ABI encode
cast abi-encode "transfer(address,uint256)" $TO $AMOUNT

# Keccak256 hash
cast keccak "Transfer(address,address,uint256)"

# Convert hex to decimal
cast --to-dec 0x1a

# Convert decimal to hex
cast --to-hex 26
```

### Reading Contract Data

```bash
# Get storage at slot
cast storage $CONTRACT $SLOT

# Get contract code
cast code $CONTRACT

# Get contract implementation (for proxies)
cast implementation $PROXY

# Get admin of proxy
cast admin $PROXY
```

## Deployment

### Script Deployment

```solidity
// script/Deploy.s.sol
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MyContract} from "../src/MyContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyContract myContract = new MyContract();

        vm.stopBroadcast();
    }
}
```

```bash
# Simulate deployment
forge script script/Deploy.s.sol

# Deploy to network
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast

# Deploy and verify
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify

# Resume failed deployment
forge script script/Deploy.s.sol --rpc-url $RPC_URL --resume
```

### Direct Deployment with Create

```bash
# Deploy contract
forge create src/MyContract.sol:MyContract \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY

# Deploy with constructor args
forge create src/MyContract.sol:MyContract \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args $ARG1 $ARG2

# Deploy and verify
forge create src/MyContract.sol:MyContract \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --verify \
    --etherscan-api-key $ETHERSCAN_KEY
```

## Verification

### Verify Contracts

```bash
# Verify on Etherscan
forge verify-contract $CONTRACT_ADDRESS \
    src/MyContract.sol:MyContract \
    --chain-id 1 \
    --etherscan-api-key $ETHERSCAN_KEY

# Verify with constructor args
forge verify-contract $CONTRACT_ADDRESS \
    src/MyContract.sol:MyContract \
    --chain-id 1 \
    --etherscan-api-key $ETHERSCAN_KEY \
    --constructor-args $(cast abi-encode "constructor(uint256)" 100)

# Verify proxy
forge verify-contract $PROXY_ADDRESS \
    src/MyProxy.sol:MyProxy \
    --chain-id 1 \
    --etherscan-api-key $ETHERSCAN_KEY \
    --verifier-url https://api.etherscan.io/api
```

## Debugging

### Debug Transactions

```bash
# Debug local transaction
forge test --debug test_MyTest

# Debug on-chain transaction
cast run $TX_HASH --debug

# Trace transaction
cast run $TX_HASH --trace
```

### Inspect Contract

```bash
# Show contract interface
forge inspect src/MyContract.sol:MyContract abi

# Show contract bytecode
forge inspect src/MyContract.sol:MyContract bytecode

# Show storage layout
forge inspect src/MyContract.sol:MyContract storage-layout

# Show all metadata
forge inspect src/MyContract.sol:MyContract metadata
```

## Formatting

### Code Formatting

```bash
# Format all files
forge fmt

# Check formatting without changes
forge fmt --check

# Format specific files
forge fmt src/MyContract.sol
```

## Configuration

### foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
optimizer = true
optimizer_runs = 200
via_ir = false
solc_version = "0.8.30"

[profile.default.fuzz]
runs = 256
max_test_rejects = 65536

[profile.default.invariant]
runs = 256
depth = 15
fail_on_revert = false

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"

[etherscan]
mainnet = { key = "${ETHERSCAN_API_KEY}" }
sepolia = { key = "${ETHERSCAN_API_KEY}" }
```

## Environment Variables

```bash
# .env file
PRIVATE_KEY=0x...
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/...
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/...
ETHERSCAN_API_KEY=...

# Load environment variables
source .env
```

## Utility Commands

```bash
# Generate documentation
forge doc

# Serve documentation locally
forge doc --serve

# Clean build artifacts
forge clean

# Show tree of dependencies
forge tree

# Flatten contract (for verification)
forge flatten src/MyContract.sol

# Generate Solidity bindings
forge bind

# Cache RPC calls for faster forking
forge cache

# Remove RPC cache
forge cache clean
```

## Anvil (Local Node)

```bash
# Start local node
anvil

# Start with specific chain ID
anvil --chain-id 31337

# Fork mainnet
anvil --fork-url $MAINNET_RPC_URL

# Fork at specific block
anvil --fork-url $MAINNET_RPC_URL --fork-block-number 18000000

# Start with specific accounts
anvil --accounts 10 --balance 10000

# Start with specific block time
anvil --block-time 12
```

## Chisel (REPL)

```bash
# Start Chisel REPL
chisel

# Inside Chisel:
# - Type Solidity code interactively
# - !help for commands
# !source - View session source
# !save - Save session
# !load - Load session
# !quit - Exit
```
