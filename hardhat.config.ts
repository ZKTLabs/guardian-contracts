import { HardhatUserConfig } from "hardhat/config";
import '@nomicfoundation/hardhat-ethers';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import '@openzeppelin/hardhat-upgrades';
import '@nomicfoundation/hardhat-chai-matchers';
import '@typechain/hardhat';
import 'hardhat-abi-exporter'
import 'hardhat-contract-sizer'
import 'hardhat-gas-reporter';
import 'solidity-coverage';


const DEFAULT_COMPILER_SETTINGS = {
  version: "0.8.20",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
      details: { yul: false },
    },
    metadata: {
      bytecodeHash: "none",
    },
  },
};

const config: HardhatUserConfig = {
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  },
  networks: {
    zkt_test: {
      url: "https://zkt-network.rpc.caldera.xyz/http",  // RPC URL Here
      chainId: 48238,
      accounts: process.env.ZK_DEPLOYER_PRIVATE_KEY !== undefined ? [process.env.ZKT_DEPLOYER_PRIVATE_KEY as string]: [],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  abiExporter: {
    runOnCompile: true,
  },
};

export default config;
