import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import {ComplianceRegistryStub_L1} from "../typechain-types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, ethers} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    const networkSupportedRegistry = await ethers.getContract(
        "NetworkSupportedRegistry"
    );
    const stub = (await ethers.getContract("ComplianceRegistryStub_L1")) as ComplianceRegistryStub_L1;
    const stubAddress = await stub.getAddress();
    const networkAddress = await networkSupportedRegistry.getAddress();
    for (let i = 0; i < 100; i++) {
        const deployedResult = await deploy(`BlacklistComplianceRegistry-${i}`, {
            from: deployer,
            contract: "ComplianceRegistry",
            proxy: {
                owner: deployer,
                execute: {
                    init: {
                        methodName: "initialize",
                        args: [deployer, false, networkAddress],
                    },
                }
            },
            log: true,
        });
        console.log(`BlacklistComplianceRegistry-${i} deployed at ${deployedResult.address}`)
        const deployedContract = await ethers.getContractAt(`BlacklistComplianceRegistry-${i}`, deployedResult.address)
        const tx0 = await deployedContract.grantRole(await deployedContract.COMPLIANCE_REGISTRY_STUB_ROLE(), stubAddress)
        await tx0.wait()
        console.log(`Granted role to stub txHash: ${tx0.hash}`)
        const tx1 = await stub.addRegistry(deployedResult.address, false)
        console.log(`Added registry txHash: ${tx1.hash}`)
        await tx1.wait()
    }
};

func.id = "deploy_multi_blacklist_compliance_registries";
func.tags = ["DeployMultiBlackComplianceRegistries"];
func.dependencies = ["DeployNetworkSupportedRegistry", "DeployComplianceRegistryStub_L1"];
export default func;
