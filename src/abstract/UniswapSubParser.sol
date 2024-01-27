// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {BaseRainterpreterSubParserNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterSubParserNPE2.sol";
import {LibSubParse, IInterpreterExternV3} from "rain.interpreter/lib/parse/LibSubParse.sol";
import {LibParseOperand} from "rain.interpreter/lib/parse/LibParseOperand.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {AuthoringMetaV2} from "rain.interpreter/interface/IParserV1.sol";
import {OPCODE_UNISWAP_V2_AMOUNT_IN, OPCODE_UNISWAP_V2_AMOUNT_OUT, OPCODE_UNISWAP_V2_QUOTE} from "./UniswapExtern.sol";

/// @dev Runtime constant form of the parse meta. Used to map stringy words into
/// indexes in roughly O(1).
bytes constant SUB_PARSER_PARSE_META =
    hex"01000000000000000000400002000000000000000000000008000000000000000000013cf36e00faeccc026bddff";

/// @dev Runtime constant form of the pointers to the word parsers.
bytes constant SUB_PARSER_WORD_PARSERS = hex"084f088908b4";

/// @dev Runtime constant form of the pointers to the operand handlers.
bytes constant SUB_PARSER_OPERAND_HANDLERS = hex"0a210a210a21";

/// @dev Index into the function pointers array for the V2 amount in.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN = 0;
/// @dev Index into the function pointers array for the V2 amount out.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT = 1;
/// @dev Index into the function pointers array for the V2 quote.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_QUOTE = 2;
/// @dev The number of function pointers in the array.
uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 3;

/// Builds the authoring meta for the sub parser. This is used both as data for
/// tooling directly, and to build the runtime parse meta.
//slither-disable-next-line dead-code
function authoringMetaV2() pure returns (bytes memory) {
    AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](SUB_PARSER_WORD_PARSERS_LENGTH);
    meta[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN] = AuthoringMetaV2(
        "uniswap-v2-amount-in",
        "Computes the minimum amount of input tokens required to get a given amount of output tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of output tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well."
    );
    meta[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT] = AuthoringMetaV2(
        "uniswap-v2-amount-out",
        "Computes the maximum amount of output tokens received from a given amount of input tokens from a UniswapV2 pair. Input/output token directions are from the perspective of the Uniswap contract. The first input is the factory address, the second is the amount of input tokens, the third is the input token address, and the fourth is the output token address. If the operand is 1 the last time the prices changed will be returned as well."
    );
    meta[SUB_PARSER_WORD_UNISWAP_V2_QUOTE] = AuthoringMetaV2(
        "uniswap-v2-quote",
        "Given an amount of token A, calculates the equivalent valued amount of token B. The first input is the factory address, the second is the amount of token A, the third is token A's address, and the fourth is token B's address. If the operand is 1 the last time the prices changed will be returned as well."
    );
    return abi.encode(meta);
}

/// @title UniswapSubParser
/// Implements the sub parser half of UniswapWords. Responsible for parsing
/// the words and operands that are used by the UniswapWords. Provides the
/// sugar required to make the externs work like native rain words.
abstract contract UniswapSubParser is BaseRainterpreterSubParserNPE2 {
    /// Allows the UniswapWords contract to feed the extern address (itself)
    /// into the sub parser functions by overriding `extern`.
    function extern() internal view virtual returns (address);

    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function subParserParseMeta() internal pure override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function subParserWordParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_WORD_PARSERS;
    }

    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function subParserOperandHandlers() internal pure override returns (bytes memory) {
        return SUB_PARSER_OPERAND_HANDLERS;
    }

    /// Create a 16-bit pointer array for the operand handlers. This is
    /// relatively gas inefficent so it is only called during tests to cross
    /// reference against the constant values that are used at runtime.
    function buildSubParserOperandHandlers() external pure returns (bytes memory) {
        function(uint256[] memory) internal pure returns (Operand)[] memory fs =
            new function(uint256[] memory) internal pure returns (Operand)[](SUB_PARSER_WORD_PARSERS_LENGTH);
        fs[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN] = LibParseOperand.handleOperandSingleFull;
        fs[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT] = LibParseOperand.handleOperandSingleFull;
        fs[SUB_PARSER_WORD_UNISWAP_V2_QUOTE] = LibParseOperand.handleOperandSingleFull;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    /// Create a 16-bit pointer array for the word parsers. This is relatively
    /// gas inefficent so it is only called during tests to cross reference
    /// against the constant values that are used at runtime.
    function buildSubParserWordParsers() external pure returns (bytes memory) {
        function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[] memory fs =
        new function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[](
            SUB_PARSER_WORD_PARSERS_LENGTH
        );
        fs[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN] = uniswapV2AmountInSubParser;
        fs[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT] = uniswapV2AmountOutSubParser;
        fs[SUB_PARSER_WORD_UNISWAP_V2_QUOTE] = uniswapV2QuoteSubParser;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the amount in opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2AmountInSubParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()),
            constantsHeight,
            inputsByte,
            Operand.unwrap(operand) & 1 > 0 ? 2 : 1,
            operand,
            OPCODE_UNISWAP_V2_AMOUNT_IN
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the amount out opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2AmountOutSubParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()),
            constantsHeight,
            inputsByte,
            Operand.unwrap(operand) & 1 > 0 ? 2 : 1,
            operand,
            OPCODE_UNISWAP_V2_AMOUNT_OUT
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the quote opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2QuoteSubParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()),
            constantsHeight,
            inputsByte,
            Operand.unwrap(operand) & 1 > 0 ? 2 : 1,
            operand,
            OPCODE_UNISWAP_V2_QUOTE
        );
    }
}
