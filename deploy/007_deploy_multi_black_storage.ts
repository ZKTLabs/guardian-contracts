import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {ComplianceRegistryStub_L1, RegistryFactory, RegistryIndexFactory} from "../typechain-types";
import {toNumber} from "ethers";
import {ethers} from "hardhat";
import fs from "fs";

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
    const stub = (await ethers.getContract("ComplianceRegistryStub_L1")) as ComplianceRegistryStub_L1;
    const stubAddress = await stub.getAddress();
    let jsonObj = fs.readFileSync("registryIndexArray.json");
    let registryIndexArray = JSON.parse(jsonObj.toString());
    if (registryIndexArray.length == 0) {
        throw new Error("registryIndexArray is empty");
    }

    /// blacklist
    let blacklistArray = []
    for (let i = 0; i < registryIndexArray.length; i++) {
        for (let j = 0; j < 4; j++) {
            const address = await registryFactory.deploy.staticCall(
                j,
                registryIndexArray[i],
                stubAddress,
                false
            );
            blacklistArray.push(address);
        }
    }
    const jsonData = JSON.stringify(blacklistArray, null, 2)
    fs.writeFileSync("blacklistArray.json", jsonData)

    for (let i = 0; i < registryIndexArray.length; i++) {
        for (let j = 0; j < 4; j++) {
            const tx = await registryFactory.deploy(
                j,
                registryIndexArray[i],
                stubAddress,
                false
            );
            await tx.wait();
        }
    }
};

func.id = "deploy_multi_black_storage";
func.tags = ["DeployMultiBlackStorage"];
func.dependencies = ["DeployComplianceRegistryStub_L1"];
export default func;
