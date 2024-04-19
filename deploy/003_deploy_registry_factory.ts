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

  await deploy("RegistryFactory", {
    from: deployer,
    args: [deployer, BigInt(ethers.hexlify(ethers.randomBytes(32)))],
    log: true,
  });
};

func.id = "deploy_registry_factory";
func.tags = ["DeployRegistryFactory"];
export default func;
