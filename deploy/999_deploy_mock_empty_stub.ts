import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("MockEmptyStub", {
    from: deployer,
    log: true,
  });
};

func.id = "deploy_mock_empty_stub";
func.tags = ["DeployMockEmptyStub"];
export default func;
