# Foundry Testing Patterns

## Test Structure

### Basic Test Setup

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MyContract} from "../src/MyContract.sol";

contract MyContractTest is Test {
    MyContract public myContract;

    address constant OWNER = address(1);
    address constant USER = address(2);

    function setUp() public {
        vm.prank(OWNER);
        myContract = new MyContract();
    }

    function test_BasicFunctionality() public {
        // Test implementation
    }
}
```

## Foundry Cheatcodes

### Account Manipulation

```solidity
// Set msg.sender for next call
vm.prank(USER);
myContract.userFunction();

// Set msg.sender for all subsequent calls
vm.startPrank(USER);
myContract.function1();
myContract.function2();
vm.stopPrank();

// Set account balance
vm.deal(USER, 100 ether);

// Set block.timestamp
vm.warp(block.timestamp + 1 days);

// Set block.number
vm.roll(block.number + 100);
```

### Expecting Reverts

```solidity
// Expect next call to revert with any reason
vm.expectRevert();
myContract.functionThatReverts();

// Expect specific revert message
vm.expectRevert("Insufficient balance");
myContract.functionThatReverts();

// Expect custom error
vm.expectRevert(MyContract.InsufficientBalance.selector);
myContract.functionThatReverts();

// Expect custom error with parameters
vm.expectRevert(
    abi.encodeWithSelector(
        MyContract.InsufficientBalance.selector,
        100,
        50
    )
);
myContract.functionThatReverts();
```

### Event Testing

```solidity
// Expect event emission
vm.expectEmit(true, true, false, true);
emit Transfer(USER, address(0), 100);
myContract.burn(100);

// Parameters: checkTopic1, checkTopic2, checkTopic3, checkData
```

### Storage Manipulation

```solidity
// Read storage slot
bytes32 value = vm.load(address(myContract), bytes32(uint(0)));

// Write to storage slot
vm.store(address(myContract), bytes32(uint(0)), bytes32(uint(100)));
```

## Fuzzing

### Basic Fuzzing

```solidity
function testFuzz_Transfer(uint256 amount) public {
    vm.assume(amount > 0 && amount <= 1000000);

    vm.deal(USER, amount);
    vm.prank(USER);
    myContract.deposit{value: amount}();

    assertEq(address(myContract).balance, amount);
}
```

### Bounded Fuzzing

```solidity
function testFuzz_WithdrawBounded(uint256 amount) public {
    amount = bound(amount, 1, 1000 ether);

    vm.deal(address(myContract), amount);
    myContract.withdraw(amount);

    assertEq(address(myContract).balance, 0);
}
```

## Invariant Testing

### Setup Invariant Tests

```solidity
contract InvariantTest is Test {
    MyContract public myContract;
    Handler public handler;

    function setUp() public {
        myContract = new MyContract();
        handler = new Handler(myContract);

        targetContract(address(handler));
    }

    function invariant_TotalSupplyEqualsSum() public {
        assertEq(
            myContract.totalSupply(),
            handler.sumOfBalances()
        );
    }
}

contract Handler {
    MyContract public myContract;
    uint256 public sumOfBalances;

    constructor(MyContract _myContract) {
        myContract = _myContract;
    }

    function mint(uint256 amount) public {
        amount = bound(amount, 0, 1000000);
        myContract.mint(msg.sender, amount);
        sumOfBalances += amount;
    }

    function burn(uint256 amount) public {
        amount = bound(amount, 0, myContract.balanceOf(msg.sender));
        myContract.burn(amount);
        sumOfBalances -= amount;
    }
}
```

## Fork Testing

### Mainnet Forking

```solidity
contract ForkTest is Test {
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant WHALE = 0x...; // Known USDC holder

    function setUp() public {
        // Fork mainnet at specific block
        vm.createSelectFork("mainnet", 18_000_000);
    }

    function test_InteractWithRealContracts() public {
        uint256 balance = USDC.balanceOf(WHALE);

        vm.prank(WHALE);
        USDC.transfer(address(this), 1000e6);

        assertEq(USDC.balanceOf(address(this)), 1000e6);
        assertEq(USDC.balanceOf(WHALE), balance - 1000e6);
    }
}
```

### Multiple Fork Management

```solidity
function test_MultipleForks() public {
    uint256 mainnetFork = vm.createFork("mainnet");
    uint256 optimismFork = vm.createFork("optimism");

    // Work on mainnet
    vm.selectFork(mainnetFork);
    // ... mainnet operations

    // Switch to optimism
    vm.selectFork(optimismFork);
    // ... optimism operations
}
```

## Gas Reporting

### Track Gas Usage

```solidity
function test_GasUsage() public {
    uint256 gasBefore = gasleft();
    myContract.expensiveFunction();
    uint256 gasUsed = gasBefore - gasleft();

    console.log("Gas used:", gasUsed);

    // Assert gas limit
    assertLt(gasUsed, 100_000);
}

// Or use snapshot
function test_GasSnapshot() public {
    vm.snapshot();
    myContract.function1();
    vm.revertTo(vm.snapshot());
    // Gas usage automatically reported in test output
}
```

## Snapshot Testing

```solidity
function test_WithSnapshot() public {
    uint256 snapshot = vm.snapshot();

    // Make changes
    myContract.setState(100);
    assertEq(myContract.getState(), 100);

    // Revert to snapshot
    vm.revertTo(snapshot);
    assertEq(myContract.getState(), 0); // State restored
}
```

## Coverage Patterns

### Comprehensive Test Coverage

```solidity
contract ComprehensiveTest is Test {
    // Test normal operation
    function test_NormalOperation() public { }

    // Test edge cases
    function test_EdgeCase_ZeroAmount() public { }
    function test_EdgeCase_MaxAmount() public { }

    // Test access control
    function test_RevertWhen_UnauthorizedCaller() public { }

    // Test state transitions
    function test_StateTransition_FromAToB() public { }

    // Test integrations
    function test_Integration_WithExternalContract() public { }

    // Fuzz tests
    function testFuzz_AllInputRanges(uint256 input) public { }

    // Invariant tests
    function invariant_CoreProperty() public { }
}
```

## Advanced Patterns

### Differential Testing

```solidity
function testFuzz_DifferentialAgainstReference(uint256 input) public {
    uint256 result1 = myContract.newImplementation(input);
    uint256 result2 = referenceContract.oldImplementation(input);
    assertEq(result1, result2);
}
```

### Time-Based Testing

```solidity
function test_VestingSchedule() public {
    myContract.startVesting(USER, 1000 ether);

    // After 1 month (30 days)
    vm.warp(block.timestamp + 30 days);
    assertEq(myContract.vestedAmount(USER), 250 ether);

    // After 2 months
    vm.warp(block.timestamp + 30 days);
    assertEq(myContract.vestedAmount(USER), 500 ether);

    // After full vesting period
    vm.warp(block.timestamp + 60 days);
    assertEq(myContract.vestedAmount(USER), 1000 ether);
}
```

### Mock Contracts

```solidity
contract MockERC20 is Test {
    function transfer(address to, uint256 amount) external returns (bool) {
        // Mock implementation
        return true;
    }

    function balanceOf(address account) external pure returns (uint256) {
        return 1000 ether;
    }
}

contract MyTest is Test {
    function test_WithMock() public {
        MockERC20 token = new MockERC20();
        myContract.setToken(address(token));
        // Test with mock
    }
}
```

## Test Organization

### File Structure

```
test/
├── unit/
│   ├── MyContract.t.sol
│   └── MyOtherContract.t.sol
├── integration/
│   └── CompleteFlow.t.sol
├── invariant/
│   ├── Invariants.t.sol
│   └── Handler.sol
├── fork/
│   └── MainnetFork.t.sol
└── mocks/
    └── MockContracts.sol
```

### Running Tests

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test test_Transfer

# Run tests in specific file
forge test --match-path test/MyContract.t.sol

# Run with gas reporting
forge test --gas-report

# Run with verbosity
forge test -vvvv

# Run with coverage
forge coverage

# Run on fork
forge test --fork-url $MAINNET_RPC_URL

# Run invariant tests
forge test --match-test invariant
```
