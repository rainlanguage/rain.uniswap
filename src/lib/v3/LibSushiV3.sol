// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UnsupportedChainId} from "../../error/ErrChainId.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_POLYGON} from "../chain/LibChainId.sol";

// List of constants from sushi.
// https://github.com/rainlanguage/sushiswap/blob/rain-fork/packages/sushi/src/config/sushiswap-v2.ts

bytes32 constant LITERAL_SUSHISWAP_V3_FACTORY = keccak256("sushi-v3-factory");
bytes32 constant LITERAL_SUSHISWAP_V3_INIT_CODE = keccak256("sushi-v3-init-code");

address constant SUSHISWAP_V3_FACTORY_ADDRESS_ETHEREUM = 0xbACEB8eC6b9355Dfc0269C18bac9d6E2Bdc29C4F;
bytes32 constant SUSHISWAP_V3_INIT_CODE_HASH_ETHEREUM =
    0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

address constant SUSHISWAP_V3_FACTORY_ADDRESS_POLYGON = 0x917933899c6a5F8E37F31E19f92CdBFF7e8FF0e2;
bytes32 constant SUSHISWAP_V3_INIT_CODE_HASH_POLYGON =
    0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

library LibSushiV3 {
    function factoryAddress() internal view returns (address) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return SUSHISWAP_V3_FACTORY_ADDRESS_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_POLYGON) {
            return SUSHISWAP_V3_FACTORY_ADDRESS_POLYGON;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }

    function initCodeHash() internal view returns (bytes32) {
        if (block.chainid == CHAIN_ID_ETHEREUM) {
            return SUSHISWAP_V3_INIT_CODE_HASH_ETHEREUM;
        } else if (block.chainid == CHAIN_ID_POLYGON) {
            return SUSHISWAP_V3_INIT_CODE_HASH_POLYGON;
        } else {
            revert UnsupportedChainId(block.chainid);
        }
    }
}
