import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { RegistryFactory } from "../typechain-types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const factory = (await ethers.getContract(
    "RegistryFactory"
  )) as RegistryFactory;
  const deployedResult = await deploy("ComplianceRegistryStub_L1", {
    from: deployer,
    proxy: {
      owner: deployer,
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer, await factory.getAddress()],
        },
      },
    },
    log: true,
  });
  const tx = await factory.grantRole(
    await factory.COMPLIANCE_REGISTRY_STUB_ROLE(),
    deployedResult.address
  );
  await tx.wait();
};

func.id = "deploy_compliance_registry_stub_l1";
func.tags = ["DeployComplianceRegistryStub_L1"];
func.dependencies = ["DeployRegistryFactory"]
export default func;
