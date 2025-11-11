# Evaluation Scenarios for rr-solidity

## Scenario 1: Basic Usage - Create ERC20 Token

**Input:** "Create a simple ERC20 token contract called MyToken with symbol MTK and 18 decimals"

**Expected Behavior:**

- Automatically activate when "ERC20" or "token contract" is mentioned
- Generate Solidity contract using OpenZeppelin
- Import ERC20 from @openzeppelin/contracts
- Set up constructor with name, symbol
- Include initial supply minting
- Follow Foundry project structure
- Add proper SPDX license and pragma
- Include NatSpec comments

**Success Criteria:**

- [ ] Contract inherits from OpenZeppelin ERC20
- [ ] SPDX-License-Identifier specified
- [ ] Pragma solidity ^0.8.0 or higher
- [ ] Constructor takes name and symbol parameters
- [ ] Initial supply minted to deployer
- [ ] Uses 18 decimals (default)
- [ ] NatSpec comments for contract and functions
- [ ] Follows naming conventions from SKILL.md

## Scenario 2: Complex Scenario - Staking Contract with Tests

**Input:** "Build a staking contract where users can stake tokens and earn rewards over time. Include reentrancy protection, pausable functionality, and comprehensive Foundry tests covering edge cases like reward calculation and emergency withdrawal."

**Expected Behavior:**

- Load skill and understand complex DeFi pattern
- Create staking contract with:
  - ReentrancyGuard from OpenZeppelin
  - Pausable from OpenZeppelin
  - Ownable for admin functions
  - Stake/unstake functions
  - Reward calculation logic
  - Emergency withdrawal
- Create comprehensive Foundry test suite:
  - Test setup with vm.prank
  - Test staking functionality
  - Test reward calculation
  - Test reentrancy protection
  - Test pause functionality
  - Test edge cases (zero stake, overflow)
  - Use fuzzing for reward calculation
- Reference security best practices
- Include events for all state changes
- Use checks-effects-interactions pattern

**Success Criteria:**

- [ ] Contract inherits ReentrancyGuard, Pausable, Ownable
- [ ] All state-changing functions have nonReentrant modifier
- [ ] Events emitted for stake, unstake, rewards
- [ ] Checks-effects-interactions pattern followed
- [ ] Reward calculation uses safe math
- [ ] Test file created in test/ directory
- [ ] Tests use vm.prank for user simulation
- [ ] Tests use vm.warp for time manipulation
- [ ] Fuzzing tests for reward calculation
- [ ] Tests cover edge cases (zero amounts, overflow)
- [ ] Tests verify reentrancy protection
- [ ] Tests verify pause functionality
- [ ] All tests pass: forge test -vvv

## Scenario 3: Error Handling - Failed Deployment Gas Issues

**Input:** "My contract deployment is failing with 'out of gas' error. The contract is around 30KB compiled."

**Expected Behavior:**

- Recognize contract size issue (>24KB limit)
- Explain Ethereum contract size limit
- Analyze contract for optimization opportunities:
  - Long error messages
  - Duplicate code
  - Large arrays/mappings
  - Unnecessary functions
- Suggest solutions:
  - Split into multiple contracts
  - Use libraries
  - Shorten error messages
  - Remove unused code
  - Use proxy pattern
- Show how to check contract size with forge
- Reference optimization patterns
- Consider using forge build --sizes

**Success Criteria:**

- [ ] Identifies 24KB contract size limit
- [ ] Runs forge build --sizes to check contract size
- [ ] Analyzes contract for size optimization
- [ ] Suggests specific optimizations based on code
- [ ] Recommends splitting large contracts
- [ ] Suggests using libraries for shared code
- [ ] Recommends proxy pattern for large contracts
- [ ] Shows how to extract functionality to libraries
- [ ] Provides refactored example
- [ ] Verifies new size after optimizations
