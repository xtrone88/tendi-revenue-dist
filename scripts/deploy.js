const { ethers, waffle } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  // We get the contract to deploy
  const KILLAz = await ethers.getContractFactory("KILLAz");
  killaz = await KILLAz.deploy(owner.address);
  await killaz.deployed();
  await killaz.setBaseURI("https://killaznft.com/api/");
  await killaz.reserveKILLAz();
  await killaz.flipSaleState();
  
  console.log("KILLAz deployed to:", killaz.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});