import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {ComplianceRegistryStub_L1, RegistryFactory, RegistryIndexFactory} from "../typechain-types";
import {toNumber} from "ethers";
import {ethers} from "hardhat";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { getNamedAccounts, deployments, ethers } = hre;
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const registryFactory = (await ethers.getContract(
        "RegistryFactory"
    )) as RegistryFactory;
    const registryIndexFactory = (await ethers.getContract(
        "RegistryIndexFactory"
    )) as RegistryIndexFactory;
    await deploy("ComplianceRegistryStub_L1", {
        from: deployer,
        proxy: {
            owner: deployer,
            execute: {
                init: {
                    methodName: "initialize",
                    args: [deployer, await registryIndexFactory.getAddress(), await registryFactory.getAddress()],
                },
                // onUpgrade:{
                //     methodName: "switchRegistry",
                //     args: [],
                // }
            },
        },
        log: true,
    });
};

func.id = "deploy_compliance_registry_stub_l1";
func.tags = ["DeployComplianceRegistryStub_L1"];
// func.dependencies = ["DeployRegistryIndexFactory"];
export default func;
