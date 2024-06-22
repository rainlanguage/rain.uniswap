// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_POLYGON} from "src/lib/chain/LibChainId.sol";

uint256 constant BLOCK_NUMBER_ETHEREUM = 19097117;
uint256 constant BLOCK_NUMBER_POLYGON = 58484437;

import {Vm} from "forge-std/Vm.sol";

library LibTestFork {
    function rpcUrlEthereum(Vm vm) internal view returns (string memory) {
        return vm.envString("RPC_URL_ETHEREUM_FORK");
    }

    function forkEthereum(Vm vm) internal {
        vm.createSelectFork(rpcUrlEthereum(vm), BLOCK_NUMBER_ETHEREUM);
        vm.chainId(CHAIN_ID_ETHEREUM);
    }

    function rpcUrlPolygon(Vm vm) internal view returns (string memory) {
        return vm.envString("RPC_URL_POLYGON_FORK");
    }

    function forkPolygon(Vm vm) internal {
        vm.createSelectFork(rpcUrlPolygon(vm), BLOCK_NUMBER_POLYGON);
        vm.chainId(CHAIN_ID_POLYGON);
    }
}
