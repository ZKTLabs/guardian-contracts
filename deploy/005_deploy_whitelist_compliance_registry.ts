import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const networkSupportedRegistry = await ethers.getContract(
    "NetworkSupportedRegistry"
  );
  await deploy("WhiteComplianceRegistry", {
    from: deployer,
    contract: "ComplianceRegistry",
    proxy: {
      owner: deployer,
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer, true, await networkSupportedRegistry.getAddress()],
        },
      },
    },
  });
};

func.id = "deploy_whitelist_compliance_registry";
func.tags = ["DeployWhiteComplianceRegistry"];
func.dependencies = ["DeployBlackComplianceRegistry"];
export default func;
