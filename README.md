# tendi-revenue-dist
### Install
yarn install
### Compile
npx hardhat compile
### deploy
Rename .env.example to .env and open it, then fill the mainnet url and account's private key.
Open the scripts/deploy.js and fill the Oracle's owner address at line 8.
npx hardhat run scripts/deploy.js --network mainnet
