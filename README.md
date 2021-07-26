# Enzyme Pies

Tokenize Enzyme vaults

## How it works

The contract `EnzymePie` uses the vault Comptroller to tokenize vault shares and handle ERC20s representing shares to users. 
The contract holds all the shares.
Users can zap into the vault calling `joinPool`.
Users can redeem underlyings by burning the tokens (calling `exitPool`).
