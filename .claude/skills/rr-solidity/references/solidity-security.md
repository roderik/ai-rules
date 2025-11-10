# Solidity Security Best Practices

## Core Vulnerability Prevention

### Reentrancy Prevention

**Pattern: Checks-Effects-Interactions (CEI)**

Always update state before making external calls:

```solidity
// VULNERABLE
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount; // State change AFTER external call
}

// SECURE
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount; // State change BEFORE external call
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

**Alternative: ReentrancyGuard**

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    function withdraw(uint amount) external nonReentrant {
        // External calls are safe within nonReentrant modifier
    }
}
```

### Integer Safety

Solidity 0.8+ has built-in overflow/underflow protection. For earlier versions, use SafeMath:

```solidity
// 0.8+ (automatic protection)
uint256 a = type(uint256).max;
a += 1; // Reverts automatically

// Pre-0.8 (requires SafeMath)
using SafeMath for uint256;
uint256 a = type(uint256).max;
a = a.add(1); // Reverts with SafeMath
```

### Access Control

**Pattern: Role-Based Access**

```solidity
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyContract is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function criticalFunction() external onlyRole(ADMIN_ROLE) {
        // Only admins can execute
    }
}
```

**Pattern: Simple Ownership**

```solidity
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    function ownerOnly() external onlyOwner {
        // Only owner can execute
    }
}
```

### Front-Running Mitigation

**Pattern: Commit-Reveal**

```solidity
mapping(address => bytes32) public commits;

function commit(bytes32 _hash) external {
    commits[msg.sender] = _hash;
}

function reveal(uint _value, bytes32 _salt) external {
    require(commits[msg.sender] == keccak256(abi.encodePacked(_value, _salt)));
    // Process the revealed value
    delete commits[msg.sender];
}
```

### Pull Over Push Pattern

Allow recipients to withdraw rather than forcing payments:

```solidity
// VULNERABLE (Push)
function distribute() external {
    for (uint i = 0; i < recipients.length; i++) {
        recipients[i].transfer(amounts[i]); // May fail and block entire function
    }
}

// SECURE (Pull)
mapping(address => uint) public pendingWithdrawals;

function withdraw() external {
    uint amount = pendingWithdrawals[msg.sender];
    require(amount > 0);
    pendingWithdrawals[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

## Gas Optimization Strategies

### Storage Optimization

```solidity
// EXPENSIVE (each uint8 uses full slot)
uint8 a;
uint8 b;
uint8 c;

// OPTIMIZED (packed into single slot)
uint8 a;
uint8 b;
uint8 c;
uint232 padding; // Explicit padding for clarity
```

### Use uint256 for Counters

```solidity
// EXPENSIVE (requires extra gas for conversion)
uint8 counter;

// OPTIMIZED (native EVM word size)
uint256 counter;
```

### Calldata vs Memory

```solidity
// EXPENSIVE
function process(uint[] memory data) external {
    // Copies data to memory
}

// OPTIMIZED
function process(uint[] calldata data) external {
    // Uses data directly from calldata
}
```

### Event Emission Over Storage

```solidity
// EXPENSIVE (storage cost)
string[] public history;

function recordAction(string memory action) external {
    history.push(action); // ~20,000 gas
}

// OPTIMIZED (event emission)
event ActionRecorded(string action, uint timestamp);

function recordAction(string memory action) external {
    emit ActionRecorded(action, block.timestamp); // ~3,000 gas
}
```

## Input Validation

Always validate inputs comprehensively:

```solidity
function transfer(address to, uint amount) external {
    require(to != address(0), "Invalid recipient");
    require(amount > 0, "Invalid amount");
    require(balances[msg.sender] >= amount, "Insufficient balance");

    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

## Emergency Mechanisms

**Pattern: Pausable Contract**

```solidity
import "@openzeppelin/contracts/security/Pausable.sol";

contract MyContract is Pausable, Ownable {
    function emergencyPause() external onlyOwner {
        _pause();
    }

    function resume() external onlyOwner {
        _unpause();
    }

    function criticalFunction() external whenNotPaused {
        // Function pauses during emergency
    }
}
```

## External Call Safety

### Call vs Transfer vs Send

```solidity
// AVOID (2300 gas limit, may break with future changes)
payable(recipient).transfer(amount);

// PREFER (forwards all gas, returns success boolean)
(bool success, ) = payable(recipient).call{value: amount}("");
require(success, "Transfer failed");
```

### Check Return Values

```solidity
// VULNERABLE
token.transfer(recipient, amount);

// SECURE
bool success = token.transfer(recipient, amount);
require(success, "Transfer failed");

// OR use SafeERC20
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;

token.safeTransfer(recipient, amount); // Reverts on failure
```

## Pre-Deployment Security Checklist

- [ ] Reentrancy protection implemented (CEI pattern or ReentrancyGuard)
- [ ] Integer overflow/underflow handled (0.8+ or SafeMath)
- [ ] Access controls on privileged functions
- [ ] Input validation on all external/public functions
- [ ] Front-running vectors identified and mitigated
- [ ] Gas optimizations applied (storage packing, uint256, calldata)
- [ ] Emergency pause mechanism for critical contracts
- [ ] External calls use proper patterns (check return values, CEI)
- [ ] Events emitted for state changes
- [ ] Pull over push for payments
- [ ] No use of tx.origin for authentication
- [ ] No delegatecall to untrusted contracts
- [ ] Proper randomness source (not block.timestamp or blockhash alone)
- [ ] Time-dependent logic uses block.timestamp, not block.number
- [ ] All contracts audited with Slither
- [ ] All contracts linted with solhint
- [ ] Test coverage >90%
- [ ] Formal verification for critical logic
- [ ] Professional audit for mainnet deployment

## Common Pitfalls

### tx.origin Authentication

```solidity
// VULNERABLE
require(tx.origin == owner);

// SECURE
require(msg.sender == owner);
```

### Block Timestamp Manipulation

```solidity
// VULNERABLE (miners can manipulate ~15 seconds)
require(block.timestamp == exactTime);

// SECURE (use ranges)
require(block.timestamp >= startTime && block.timestamp <= endTime);
```

### Unchecked Low-Level Calls

```solidity
// VULNERABLE
address(target).call(data);

// SECURE
(bool success, bytes memory result) = address(target).call(data);
require(success, "Call failed");
```

### Delegatecall Dangers

```solidity
// VULNERABLE (untrusted contract can modify storage)
address(untrustedContract).delegatecall(data);

// SECURE (only delegatecall to trusted, immutable addresses)
address(trustedLibrary).delegatecall(data);
```
