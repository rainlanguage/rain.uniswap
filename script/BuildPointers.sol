// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";

import {UniswapWords} from "src/concrete/UniswapWords.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";
import {LibUniswapSubParser, PARSE_META_BUILD_DEPTH} from "../src/abstract/UniswapSubParser.sol";
import {UniswapExternConfig} from "../src/abstract/UniswapExtern.sol";

contract BuildPointers is Script {
    function buildUniswapWordsPointers() internal {
        UniswapWords words = new UniswapWords(UniswapExternConfig({v2Factory: address(0), v3Quoter: address(0)}));

        string memory name = "UniswapWords";

        LibFs.buildFileForContract(
            vm,
            address(words),
            name,
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibCodeGen.parseMetaConstantString(vm, LibUniswapSubParser.authoringMetaV2(), PARSE_META_BUILD_DEPTH),
                LibCodeGen.subParserWordParsersConstantString(vm, words),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, words),
                LibCodeGen.integrityFunctionPointersConstantString(vm, words),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, words)
            )
        );
    }

    function run() external {
        buildUniswapWordsPointers();
    }
}
