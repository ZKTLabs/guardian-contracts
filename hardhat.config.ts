import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy"
import "@openzeppelin/hardhat-upgrades"

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
        details: {
          yul: true
        }
      }
    }
  },
  networks: {
    zkt_test: {
      url: "https://zkt-network.rpc.caldera.xyz/http",  // RPC URL Here
      chainId: 48238,
      accounts: [process.env.ZKT_DEPLOYER_PRIVATE_KEY],
    }
  }
};

export default config;
