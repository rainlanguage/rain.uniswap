// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";

uint256 constant BLOCK_NUMBER = 19097117;

import {Vm} from "forge-std/Vm.sol";

library LibFork {
    function rpcUrl(Vm vm) internal view returns (string memory) {
        return vm.envString("RPC_URL_ETHEREUM_FORK");
    }
}
