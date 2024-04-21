import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {ComplianceRegistryStub_L1, RegistryFactory, RegistryIndexFactory} from "../typechain-types";
import {toNumber} from "ethers";

import fs from 'fs';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, ethers} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    const registryIndexFactory = (await ethers.getContract(
        "RegistryIndexFactory"
    )) as RegistryIndexFactory;
    const stub = (await ethers.getContract("ComplianceRegistryStub_L1")) as ComplianceRegistryStub_L1;
    const BASE_MODE = toNumber(await stub.BASE_MODE());
    const stubAddress = await stub.getAddress();
    // let jsonObj = fs.readFileSync("registryIndexArray.json");
    // let registryIndexArray = JSON.parse(jsonObj.toString());
    // if (registryIndexArray.length == 0) {
    //     throw new Error("registryIndexArray is empty");
    // }
    let registryIndexArray = [];
    /// index
    for (let i = 0; i < BASE_MODE; i++) {
        const address = await registryIndexFactory.deploy.staticCall(
            i,
            stubAddress
        );
        registryIndexArray.push(address)
    }
    let jsonData = JSON.stringify(registryIndexArray, null, 2);
    fs.writeFileSync("registryIndexArray.json", jsonData)

    for (let i = 0; i < BASE_MODE; i++) {
        const tx = await registryIndexFactory.deploy(i, stubAddress, {gasPrice: 15544294392});
        await tx.wait()
        console.log(`finish index: ${i}, contractAddr: ${registryIndexArray[i]}`)
    }
};

func.id = "deploy_multi_index";
func.tags = ["DeployMultiIndex"];
// func.dependencies = ["DeployComplianceRegistryStub_L1"];
export default func;
