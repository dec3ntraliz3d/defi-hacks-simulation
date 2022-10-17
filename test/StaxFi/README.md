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
