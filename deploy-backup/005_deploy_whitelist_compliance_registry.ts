import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const networkSupportedRegistry = await ethers.getContract(
    "NetworkSupportedRegistry"
  );
  const networkAddress = await networkSupportedRegistry.getAddress();
  await deploy("WhitelistComplianceRegistry", {
    from: deployer,
    contract: "ComplianceRegistry",
    proxy: {
      owner: deployer,
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer, true, networkAddress],
        },
      },
    },
    log: true,
  });
};

func.id = "deploy_whitelist_compliance_registry";
func.tags = ["DeployWhitelistComplianceRegistry"];
func.dependencies = ["DeployBlacklistComplianceRegistry"];
export default func;
