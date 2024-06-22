// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UnsupportedChainId} from "../../error/ErrChainId.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_POLYGON} from "../chain/LibChainId.sol";

// List of constants from sushi.
// https://github.com/rainlanguage/sushiswap/blob/rain-fork/packages/sushi/src/config/sushiswap-v2.ts

bytes32 constant LITERAL_SUSHISWAP_V2_FACTORY = keccak256("sushi-v2-factory");
bytes32 constant LITERAL_SUSHISWAP_V2_INIT_CODE = keccak256("sushi-v2-init-code");

address constant SUSHISWAP_V2_FACTORY_ADDRESS_ETHEREUM = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
bytes32 constant SUSHISWAP_V2_INIT_CODE_HASH_ETHEREUM = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;

address constant SUSHISWAP_V2_FACTORY_ADDRESS_POLYGON = 0xc35DADB65012eC5796536bD9864eD8773aBc74C4;
bytes32 constant SUSHISWAP_V2_INIT_CODE_HASH_POLYGON = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;

library LibSushiV2 {
    function factoryAddress() internal view returns (address) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return SUSHISWAP_V2_FACTORY_ADDRESS_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_POLYGON) {
            return SUSHISWAP_V2_FACTORY_ADDRESS_POLYGON;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }

    function initCodeHash() internal view returns (bytes32) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return SUSHISWAP_V2_INIT_CODE_HASH_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_POLYGON) {
            return SUSHISWAP_V2_INIT_CODE_HASH_POLYGON;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }
}