"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
async function main() {
    const [deployer] = await hardhat_1.ethers.getSigners();
    console.log(`Deploying GuardianVoterLicense by deployer ${deployer.address}`);
    const GuardianVoterLicense = await hardhat_1.ethers.getContractFactory("GuardianVoterLicense");
    const guardianVoterLicense = await hardhat_1.upgrades.deployProxy(GuardianVoterLicense, [deployer.address, 0, 0]);
    console.log(`GuardianVoterLicense deployed to ${await guardianVoterLicense.getAddress()}`);
}
main()
    .catch(error => {
    console.error(error);
    process.exit(1);
});
