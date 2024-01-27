// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {
    UniswapExternConfig,
    UniswapWords,
    INTEGRITY_FUNCTION_POINTERS,
    SUB_PARSER_OPERAND_HANDLERS,
    OPCODE_FUNCTION_POINTERS,
    SUB_PARSER_WORD_PARSERS,
    SUB_PARSER_PARSE_META,
    AuthoringMetaV2,
    authoringMetaV2
} from "src/concrete/UniswapWords.sol";
import {LibParseMeta} from "rain.interpreter/lib/parse/LibParseMeta.sol";

contract UniswapWordsPointersTest is Test {
    function testIntegrityPointers() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(address(0)));
        assertEq(INTEGRITY_FUNCTION_POINTERS, uniswapWords.buildIntegrityFunctionPointers());
    }

    function testOpcodePointers() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(address(0)));
        assertEq(OPCODE_FUNCTION_POINTERS, uniswapWords.buildOpcodeFunctionPointers());
    }

    function testSubParserWordParsers() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(address(0)));
        assertEq(SUB_PARSER_WORD_PARSERS, uniswapWords.buildSubParserWordParsers());
    }

    function testSubParserOperandHandlers() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(address(0)));
        assertEq(SUB_PARSER_OPERAND_HANDLERS, uniswapWords.buildSubParserOperandHandlers());
    }

    function testSubParserParseMeta() external {
        bytes memory authoringMetaBytes = authoringMetaV2();
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory expected = LibParseMeta.buildParseMetaV2(authoringMeta, 2);
        assertEq(SUB_PARSER_PARSE_META, expected);
    }
}
