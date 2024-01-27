// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

uint256 constant BLOCK_NUMBER = 19097117;

address constant QUOTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

import {Vm} from "forge-std/Vm.sol";

library LibFork {
    function rpcUrl(Vm vm) internal view returns (string memory) {
        return vm.envString("RPC_URL_ETHEREUM_FORK");
    }
}
