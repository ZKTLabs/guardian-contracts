import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {ComplianceVersionedMerkleTreeStub, MockComplianceVersionedMerkleTreeStubHook} from "../typechain-types";
import {StandardMerkleTree} from "@openzeppelin/merkle-tree";
import fs from "fs";
import {assert} from "chai";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, ethers} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    let mocked = true;
    let instance;
    if (mocked) {
        await deploy("MockComplianceVersionedMerkleTreeStubHook", {from: deployer, log: true})
        instance = await ethers.getContract("MockComplianceVersionedMerkleTreeStubHook") as MockComplianceVersionedMerkleTreeStubHook;
    } else {
        await deploy("ComplianceVersionedMerkleTreeStub", {from: deployer, log: true, args: [deployer]})
        instance = await ethers.getContract("ComplianceVersionedMerkleTreeStub") as ComplianceVersionedMerkleTreeStub;
    }
    const dump = JSON.parse(fs.readFileSync("./merkleTreeData.json", 'utf-8'));
    assert(dump.format === "standard-v1")
    const tree = StandardMerkleTree.load(dump)
    tree.validate();
    const version = dump.values[0].value[3]
    const tx = await instance.updateVersionedMerkleTree(tree.root, version, true);
    await tx.wait()
};

func.id = "deploy_compliance_versioned_merkle_tree";
func.tags = ["DeployComplianceVersionedMerkleTreeStub"];
export default func;
