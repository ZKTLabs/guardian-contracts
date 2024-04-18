import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ComplianceRegistry } from "../typechain-types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const white = (await ethers.getContract(
    "WhitelistComplianceRegistry"
  )) as ComplianceRegistry;
  const black = (await ethers.getContract(
    "BlacklistComplianceRegistry"
  )) as ComplianceRegistry;
  const deployedResult = await deploy("ComplianceRegistryStub_L1", {
    from: deployer,
    proxy: {
      owner: deployer,
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer],
        },
      },
    },
    log: true
  });
  const tx0 = await white.grantRole(
    await white.COMPLIANCE_REGISTRY_STUB_ROLE(),
    deployedResult.address
  );
  await tx0.wait();
  const tx1 = await black.grantRole(
    await white.COMPLIANCE_REGISTRY_STUB_ROLE(),
    deployedResult.address
  );
  await tx1.wait();
  const stub = await ethers.getContractAt(
    "ComplianceRegistryStub_L1",
    deployedResult.address
  );
  const tx2 = await stub.grantRole(await stub.GUARDIAN_NODE(), deployer);
  await tx2.wait();
};

func.id = "deploy_compliance_registry_stub_l1";
func.tags = ["DeployComplianceRegistryStub_L1"];
func.dependencies = ["DeployWhitelistComplianceRegistry"];
export default func;
