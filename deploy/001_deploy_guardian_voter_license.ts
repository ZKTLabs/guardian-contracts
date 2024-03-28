import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("GuardianVoterLicense", {
    from: deployer,
    proxy: {
      execute: { init: { methodName: "initialize", args: [deployer, 0, 0] } },
    },
    log: true,
  });
};

func.id = "deploy_guardian_voter_license";
func.tags = ["DeployGuardianVoterLicense"];
export default func;
