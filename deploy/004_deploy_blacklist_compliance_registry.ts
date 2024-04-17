import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const networkSupportedRegistry = await ethers.getContract(
    "NetworkSupportedRegistry"
  );
  await deploy("BlackComplianceRegistry-1", {
    from: deployer,
    contract: "ComplianceRegistry",
    proxy: {
      owner: deployer,
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer, false, await networkSupportedRegistry.getAddress()],
        },
      },
    },
    log: true,
  });
};

func.id = "deploy_blacklist_compliance_registry";
func.tags = ["DeployBlackComplianceRegistry"];
func.dependencies = ["DeployNetworkSupportedRegistry"];
export default func;
