import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const supportedNetworkNames = [
  "arb",
  "arbitrum",
  "op",
  "optimistic",
  "eth",
  "goerli",
  "sepolia",
  "btcl2",
  "bsc",
];

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const deployResulted = await deploy("NetworkSupportedRegistry", {
    from: deployer,
    log: true,
  });
  const networkSupportedRegistry = await ethers.getContractAt(
    "NetworkSupportedRegistry",
    deployResulted.address
  );
  // const tx = await networkSupportedRegistry["batchAddNetworks(string[])"](
  //   supportedNetworkNames
  // );
  // await tx.wait();
  // console.log(`batchAddNetworks finish: ${tx.hash}`);
};

func.id = "deploy_network_supported_registry";
func.tags = ["DeployNetworkSupportedRegistry"];
export default func;
