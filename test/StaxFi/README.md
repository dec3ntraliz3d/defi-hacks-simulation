### stax.fi got hacked on Oct11 2022 . Hacker found a vulnerability in the Staking contract's migrateStake function. This function doesn't verify oldstaking contract address and also allow anyone to call the function. Which was a big mistake.

```
function migrateStake(address oldStaking, uint256 amount) external {
       StaxLPStaking(oldStaking).migrateWithdraw(msg.sender, amount);
       _applyStake(msg.sender, amount);
   }
```

### This test simulates the hack. Foundry's mainnet fork functionality was used . We chose block 15725066 which is the block before that hack.

```
forge test --match-contract StaxFiHack --fork-url "your_alchemy_mainnet_url" --fork-block-number 15725066

```

### Below is the transaction details of the hack.

```
https://tx.eth.samczsun.com/ethereum/0x8c3f442fc6d640a6ff3ea0b12be64f1d4609ea94edd2966f42c01cd9bdcf04b5
```
