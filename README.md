# tendi-revenue-dist
> Current project is based on nodejs 16.12 and yarn 1.22.17
### Download from github
Download zip file or git clone https://github.com/zess11/tendi-revenue-dist.git<br>
### Install
Go to the source directory and open command line, please run<br>
> yarn install
### Config
Rename .env.example to .env and open it, then fill the mainnet url and account's private key. for example<br>
![image](https://user-images.githubusercontent.com/82226713/140091960-48f40dde-0207-4506-a7f3-fcda524f5eb9.png)
As you can see, you just copy and past your mainnet's infra url and account's private key for deploying.<br>
Open the scripts/deploy.js and fill the Oracle's owner address at line 8.<br>
> npx hardhat run scripts/deploy.js --network mainnet
### Compile
> npx hardhat compile
