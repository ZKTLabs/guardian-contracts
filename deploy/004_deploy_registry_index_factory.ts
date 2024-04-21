import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { getNamedAccounts, deployments, ethers } = hre;
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const registryFactory = await ethers.getContract("RegistryFactory")
    await deploy("RegistryIndexFactory", {
        from: deployer,
        args: [BigInt(ethers.hexlify(ethers.randomBytes(32))), deployer, await registryFactory.getAddress()],
        log: true,
    });
};

func.id = "deploy_registry_index_factory";
func.tags = ["DeployRegistryIndexFactory"];
func.dependencies = ["DeployRegistryFactory"];
export default func;
