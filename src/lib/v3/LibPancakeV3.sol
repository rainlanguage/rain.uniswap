// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UnsupportedChainId} from "../../error/ErrChainId.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_BSC} from "../chain/LibChainId.sol";

// https://github.com/rainlanguage/sushiswap/blob/rain-fork/packages/sushi/src/router/liquidity-providers/PancakeSwapV2.ts

bytes32 constant LITERAL_PANCAKE_V3_FACTORY = keccak256("pancake-v3-factory");
bytes32 constant LITERAL_PANCAKE_V3_INIT_CODE = keccak256("pancake-v3-init-code");

address constant PANCAKE_V3_FACTORY_ADDRESS_ETHEREUM = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9;
bytes32 constant PANCAKE_V3_INIT_CODE_HASH_ETHEREUM = 0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2;

address constant PANCAKE_V3_FACTORY_ADDRESS_BSC = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9;
bytes32 constant PANCAKE_V3_INIT_CODE_HASH_BSC = 0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2;

library LibPancakeV3 {
    function factoryAddress() internal view returns (address) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return PANCAKE_V3_FACTORY_ADDRESS_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_BSC) {
            return PANCAKE_V3_FACTORY_ADDRESS_BSC;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }

    function initCodeHash() internal view returns (bytes32) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return PANCAKE_V3_INIT_CODE_HASH_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_BSC) {
            return PANCAKE_V3_INIT_CODE_HASH_BSC;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }
}
