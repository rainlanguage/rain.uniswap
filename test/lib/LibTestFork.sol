// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";

uint256 constant BLOCK_NUMBER = 19097117;

address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
address constant UNISWAP_V3_QUOTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

import {Vm} from "forge-std/Vm.sol";

library LibFork {
    function rpcUrl(Vm vm) internal view returns (string memory) {
        return vm.envString("RPC_URL_ETHEREUM_FORK");
    }

    function newUniswapWords() internal returns (UniswapWords) {
        return new UniswapWords(UniswapExternConfig(UNISWAP_V2_FACTORY, UNISWAP_V3_FACTORY, UNISWAP_V3_QUOTER));
    }
}
