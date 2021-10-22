const { expect } = require("chai");

describe("Revenue contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const Revenue = await ethers.getContractFactory("Revenue");

    const revenue = await Revenue.deploy();
    
  });
});
