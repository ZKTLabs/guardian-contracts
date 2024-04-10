import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("GuardianNode", {
    from: deployer,
    log: true,
  });
};

func.id = "deploy_guardian_node";
func.tags = ["DeployGuardianNode"];
export default func;
