import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ComplianceRegistry } from "../typechain-types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const white = (await ethers.getContract(
    "WhiteComplianceRegistry"
  )) as ComplianceRegistry;
  const black = (await ethers.getContract(
    "BlackComplianceRegistry"
  )) as ComplianceRegistry;
  const deployedResult = await deploy("ComplianceRegistryStub", {
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
};

func.id = "deploy_compliance_registry_stub";
func.tags = ["DeployComplianceRegistryStub"];
func.dependencies = ["DeployWhiteComplianceRegistry"];
export default func;
