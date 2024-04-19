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


const {
  SEPOLIA_DEPLOYER,
  ZKT_DEPLOYER,
  INFURA_API_KEY,
} = process.env

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
    hardhat: {
      // forking: {
      //   // url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      //   url: "https://zkt-network.rpc.caldera.xyz/http",  // RPC URL Here
      // },
      gasPrice: 1052989477
    },
    zkt_test: {
      url: "https://zkt-network.rpc.caldera.xyz/http",  // RPC URL Here
      chainId: 48238,
      accounts:  [ZKT_DEPLOYER as string],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [SEPOLIA_DEPLOYER as string]
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  abiExporter: {
    runOnCompile: true,
  },
  mocha: {
    timeout: 60000
  }
};

export default config;
