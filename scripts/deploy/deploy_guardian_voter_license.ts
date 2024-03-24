import {ethers, upgrades} from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying GuardianVoterLicense by deployer ${deployer.address}`);
  const GuardianVoterLicense = await ethers.getContractFactory("GuardianVoterLicense");
  const guardianVoterLicense = await upgrades.deployProxy(GuardianVoterLicense, [deployer.address, 0, 0], );
  console.log(`GuardianVoterLicense deployed to ${await guardianVoterLicense.getAddress()}`);
}

main()
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

