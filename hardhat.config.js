"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
const config = {
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
            url: "https://zkt-network.rpc.caldera.xyz/http",
            chainId: 48238,
            accounts: [process.env.ZKT_DEPLOYER_PRIVATE_KEY],
        }
    }
};
exports.default = config;
