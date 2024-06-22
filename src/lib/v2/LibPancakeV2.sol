// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UnsupportedChainId} from "../../error/ErrChainId.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_BSC} from "../chain/LibChainId.sol";

// https://github.com/rainlanguage/sushiswap/blob/rain-fork/packages/sushi/src/router/liquidity-providers/PancakeSwapV2.ts

bytes32 constant LITERAL_PANCAKE_V2_FACTORY = keccak256("pancake-v2-factory");
bytes32 constant LITERAL_PANCAKE_V2_INIT_CODE = keccak256("pancake-v2-init-code");

address constant PANCAKE_V2_FACTORY_ADDRESS_ETHEREUM = 0x1097053Fd2ea711dad45caCcc45EfF7548fCB362;
bytes32 constant PANCAKE_V2_INIT_CODE_HASH_ETHEREUM = 0x57224589c67f3f30a6b0d7a1b54cf3153ab84563bc609ef41dfb34f8b2974d2d;

address constant PANCAKE_V2_FACTORY_ADDRESS_BSC = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
bytes32 constant PANCAKE_V2_INIT_CODE_HASH_BSC = 0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;

library LibPancakeV2 {
    function factoryAddress() internal view returns (address) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return PANCAKE_V2_FACTORY_ADDRESS_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_BSC) {
            return PANCAKE_V2_FACTORY_ADDRESS_BSC;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }

    function initCodeHash() internal view returns (bytes32) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return PANCAKE_V2_INIT_CODE_HASH_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_BSC) {
            return PANCAKE_V2_INIT_CODE_HASH_BSC;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }
}
