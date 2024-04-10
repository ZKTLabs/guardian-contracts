import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {getNamedAccounts, deployments, ethers} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    const white = await ethers.getContract("WhiteComplianceRegistry")
    const black = await ethers.getContract("BlackComplianceRegistry")
    await deploy("ComplianceRegistryStub_L1", {
        from: deployer,
        args: [await white.getAddress(), await black.getAddress()],
        log: true,
    });
};

func.id = "deploy_compliance_registry_stub_l1";
func.tags = ["DeployComplianceRegistryStub_L1"];
func.dependencies = ["DeployWhiteComplianceRegistry"]
export default func;
