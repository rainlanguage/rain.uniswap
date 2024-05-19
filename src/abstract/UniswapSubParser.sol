// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {BaseRainterpreterSubParserNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterSubParserNPE2.sol";
import {LibSubParse, IInterpreterExternV3} from "rain.interpreter/lib/parse/LibSubParse.sol";
import {LibParseOperand} from "rain.interpreter/lib/parse/LibParseOperand.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {AuthoringMetaV2} from "rain.interpreter.interface/interface/IParserV1.sol";
import {
    OPCODE_UNISWAP_V2_AMOUNT_IN,
    OPCODE_UNISWAP_V2_AMOUNT_OUT,
    OPCODE_UNISWAP_V2_QUOTE,
    OPCODE_UNISWAP_V3_EXACT_OUTPUT,
    OPCODE_UNISWAP_V3_EXACT_INPUT,
    OPCODE_UNISWAP_V3_TWAP
} from "./UniswapExtern.sol";

bytes32 constant DESCRIBED_BY_META_V1 = bytes32(0x4354486f79f4ec94e40bc0afe8264fc2c993bf05781b311bcbc1d5dd71237577);

/// @dev Runtime constant form of the parse meta. Used to map stringy words into
/// indexes in roughly O(1).
bytes constant SUB_PARSER_PARSE_META =
    hex"010000000000040000000000008800000000020000a0000000000000000000000000059852a103fd758204722c3102fe814f01b519ad007b1e62";

/// @dev Runtime constant form of the pointers to the word parsers.
bytes constant SUB_PARSER_WORD_PARSERS = hex"0d180d3a0d4d0d600d730d86";

/// @dev Runtime constant form of the pointers to the operand handlers.
bytes constant SUB_PARSER_OPERAND_HANDLERS = hex"1a161a161a161a7b1a7b1a7b";

/// @dev Runtime constant form of the pointers to the literal parsers.
bytes constant SUB_PARSER_LITERAL_PARSERS = hex"1a0d";

/// @dev Index into the function pointers array for the V2 amount in.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN = 0;
/// @dev Index into the function pointers array for the V2 amount out.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT = 1;
/// @dev Index into the function pointers array for the V2 quote.
uint256 constant SUB_PARSER_WORD_UNISWAP_V2_QUOTE = 2;
/// @dev Index into the function pointers array for the V3 exact output.
uint256 constant SUB_PARSER_WORD_UNISWAP_V3_EXACT_OUTPUT = 3;
/// @dev Index into the function pointers array for the V3 exact input.
uint256 constant SUB_PARSER_WORD_UNISWAP_V3_EXACT_INPUT = 4;
/// @dev Index into the function pointers array for the V3 twap.
uint256 constant SUB_PARSER_WORD_UNISWAP_V3_TWAP = 5;
/// @dev The number of function pointers in the array.
uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 6;

library LibUniswapSubParser {
    /// Builds the authoring meta for the sub parser. This is used both as data for
    /// tooling directly, and to build the runtime parse meta.
    //slither-disable-next-line dead-code
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](SUB_PARSER_WORD_PARSERS_LENGTH);
        meta[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_IN] = AuthoringMetaV2(
            "uniswap-v2-quote-exact-output",
            "Quotes the minimum absolute amount of input tokens required to get a given amount of output tokens from a Uniswap V2 pair. Input/output token directions are from the perspective of the Uniswap pool contract. The first input is the input token address, the second is the output token address, and the third is the amount of output tokens. If the operand is 1 the last time the prices changed will be returned as well."
        );
        meta[SUB_PARSER_WORD_UNISWAP_V2_AMOUNT_OUT] = AuthoringMetaV2(
            "uniswap-v2-quote-exact-input",
            "Computes the maximum amount of output tokens received from a given amount of input tokens from a Uniswap V2 pair. Input/output token directions are from the perspective of the Uniswap pool contract. The first input is the input token address, the second is the output token address, and the third is the amount of input tokens. If the operand is 1 the last time the prices changed will be returned as well."
        );
        meta[SUB_PARSER_WORD_UNISWAP_V2_QUOTE] = AuthoringMetaV2(
            "uniswap-v2-spot-output-ratio",
            "The current instantaneous \"spot\" output ratio (output per unit of input) of a given token pair. Input/output token directions are from the perspective of the Uniswap pool contract. The first and second inputs are the input token address and decimals, the third and fourth are the output token address and decimals. If the operand is 1 the last time the ratio changed will be returned as well."
        );
        meta[SUB_PARSER_WORD_UNISWAP_V3_EXACT_OUTPUT] = AuthoringMetaV2(
            "uniswap-v3-quote-exact-output",
            "Quotes the minimum absolute amount of input tokens required to get a given exact amount of output tokens from a Uniswap V3 pair. Input/output token directions are from the perspective of the Uniswap pool contract. The first input is the input token address, the second is the output token address, the third is the exact output amount, and the fourth is the pool fee."
        );
        meta[SUB_PARSER_WORD_UNISWAP_V3_EXACT_INPUT] = AuthoringMetaV2(
            "uniswap-v3-quote-exact-input",
            "Quotes the maximum amount of output tokens received from a given amount of input tokens from a Uniswap V3 pair. Input/output token directions are from the perspective of the Uniswap pool contract. The first input is the input token address, the second is the output token address, the third is the exact input amount, and the fourth is the pool fee."
        );
        meta[SUB_PARSER_WORD_UNISWAP_V3_TWAP] = AuthoringMetaV2(
            "uniswap-v3-twap-output-ratio",
            "The time weighted average output ratio (output per unit of input) of a given token pair over a given period of time, as an 18 decimal fixed point ratio. Input/output token directions are from the perspective of the Uniswap pool contract. The first and second inputs are the input token address and decimals, the third and fourth are the output token address and decimals, the fifth and sixth are the start and end times ago in seconds, and the seventh is the pool fee. If the start and end times are both 0, returns the current instantaneous \"spot\" ratio rather than an average. Note that uniswap TWAP prices suffer lossy compression as they are converted to/from \"ticks\" so are only accurate to within 0.01%."
        );
        return abi.encode(meta);
    }
}

uint256 constant SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX = 0;

/// @dev The literal string for the high fee UniswapV3 pool.
bytes constant LITERAL_UNISWAP_V3_FEE_HIGH = "uniswap-v3-fee-high";
uint256 constant LITERAL_UNISWAP_V3_FEE_HIGH_LENGTH = 19;
uint256 constant LITERAL_UNISWAP_V3_FEE_HIGH_MASK = ~((1 << ((0x20 - LITERAL_UNISWAP_V3_FEE_HIGH_LENGTH) * 8)) - 1);
/// @dev The value that is returned when the high fee UniswapV3 pool is used.
/// https://docs.uniswap.org/sdk/v3/reference/enums/FeeAmount#high
uint256 constant LITERAL_UNISWAP_V3_FEE_HIGH_VALUE = 10000;

/// @dev The literal string for the medium fee UniswapV3 pool.
bytes constant LITERAL_UNISWAP_V3_FEE_MEDIUM = "uniswap-v3-fee-medium";
uint256 constant LITERAL_UNISWAP_V3_FEE_MEDIUM_LENGTH = 21;
uint256 constant LITERAL_UNISWAP_V3_FEE_MEDIUM_MASK = ~((1 << ((0x20 - LITERAL_UNISWAP_V3_FEE_MEDIUM_LENGTH) * 8)) - 1);
/// @dev The value that is returned when the medium fee UniswapV3 pool is used.
/// https://docs.uniswap.org/sdk/v3/reference/enums/FeeAmount#medium
uint256 constant LITERAL_UNISWAP_V3_FEE_MEDIUM_VALUE = 3000;

/// @dev The literal string for the low fee UniswapV3 pool.
bytes constant LITERAL_UNISWAP_V3_FEE_LOW = "uniswap-v3-fee-low";
uint256 constant LITERAL_UNISWAP_V3_FEE_LOW_LENGTH = 18;
uint256 constant LITERAL_UNISWAP_V3_FEE_LOW_MASK = ~((1 << ((0x20 - LITERAL_UNISWAP_V3_FEE_LOW_LENGTH) * 8)) - 1);
/// @dev The value that is returned when the low fee UniswapV3 pool is used.
/// https://docs.uniswap.org/sdk/v3/reference/enums/FeeAmount#low
uint256 constant LITERAL_UNISWAP_V3_FEE_LOW_VALUE = 500;

/// @dev The literal string for the lowest fee UniswapV3 pool.
bytes constant LITERAL_UNISWAP_V3_FEE_LOWEST = "uniswap-v3-fee-lowest";
uint256 constant LITERAL_UNISWAP_V3_FEE_LOWEST_LENGTH = 21;
uint256 constant LITERAL_UNISWAP_V3_FEE_LOWEST_MASK = ~((1 << ((0x20 - LITERAL_UNISWAP_V3_FEE_LOWEST_LENGTH) * 8)) - 1);
/// @dev The value that is returned when the lowest fee UniswapV3 pool is used.
/// https://docs.uniswap.org/sdk/v3/reference/enums/FeeAmount#lowest
uint256 constant LITERAL_UNISWAP_V3_FEE_LOWEST_VALUE = 100;

/// @title UniswapSubParser
/// Implements the sub parser half of UniswapWords. Responsible for parsing
/// the words and operands that are used by the UniswapWords. Provides the
/// sugar required to make the externs work like native rain words.
abstract contract UniswapSubParser is BaseRainterpreterSubParserNPE2 {
    function describedByMetaV1() external pure returns (bytes32) {
        return DESCRIBED_BY_META_V1;
    }

    /// Allows the UniswapWords contract to feed the extern address (itself)
    /// into the sub parser functions by overriding `extern`.
    function extern() internal view virtual returns (address);

    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function subParserParseMeta() internal pure override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    //slither-disable-next-line dead-code
    function parseUniswapV3Fee(uint256 value, uint256, uint256) internal pure returns (uint256) {
        return value;
    }

    /// Overrides the base literal parsers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserLiteralParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_LITERAL_PARSERS;
    }

    function buildSubParserLiteralParsers() external pure returns (bytes memory) {
        unchecked {
            function (uint256, uint256, uint256) internal pure returns (uint256)[] memory fs =
                new function (uint256, uint256, uint256) internal pure returns (uint256)[](1);
            fs[SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX] = parseUniswapV3Fee;

            uint256[] memory pointers;
            assembly ("memory-safe") {
                pointers := fs
            }
            return LibConvert.unsafeTo16BitBytes(pointers);
        }
    }

    function matchSubParseLiteralDispatch(uint256 cursor, uint256 end)
        internal
        pure
        virtual
        override
        returns (bool, uint256, uint256)
    {
        uint256 loaded;
        assembly ("memory-safe") {
            loaded := mload(cursor)
        }
        if (
            end - cursor == bytes(LITERAL_UNISWAP_V3_FEE_HIGH).length
                && loaded & LITERAL_UNISWAP_V3_FEE_HIGH_MASK == uint256(bytes32(LITERAL_UNISWAP_V3_FEE_HIGH))
        ) {
            return (true, SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX, LITERAL_UNISWAP_V3_FEE_HIGH_VALUE);
        } else if (
            end - cursor == bytes(LITERAL_UNISWAP_V3_FEE_MEDIUM).length
                && loaded & LITERAL_UNISWAP_V3_FEE_MEDIUM_MASK == uint256(bytes32(LITERAL_UNISWAP_V3_FEE_MEDIUM))
        ) {
            return (true, SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX, LITERAL_UNISWAP_V3_FEE_MEDIUM_VALUE);
        } else if (
            end - cursor == bytes(LITERAL_UNISWAP_V3_FEE_LOW).length
                && loaded & LITERAL_UNISWAP_V3_FEE_LOW_MASK == uint256(bytes32(LITERAL_UNISWAP_V3_FEE_LOW))
        ) {
            return (true, SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX, LITERAL_UNISWAP_V3_FEE_LOW_VALUE);
        } else if (
            end - cursor == bytes(LITERAL_UNISWAP_V3_FEE_LOWEST).length
                && loaded & LITERAL_UNISWAP_V3_FEE_LOWEST_MASK == uint256(bytes32(LITERAL_UNISWAP_V3_FEE_LOWEST))
        ) {
            return (true, SUB_PARSER_LITERAL_UNISWAP_V3_FEE_INDEX, LITERAL_UNISWAP_V3_FEE_LOWEST_VALUE);
        } else {
            return (false, 0, 0);
        }
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
        fs[SUB_PARSER_WORD_UNISWAP_V3_EXACT_OUTPUT] = LibParseOperand.handleOperandDisallowed;
        fs[SUB_PARSER_WORD_UNISWAP_V3_EXACT_INPUT] = LibParseOperand.handleOperandDisallowed;
        fs[SUB_PARSER_WORD_UNISWAP_V3_TWAP] = LibParseOperand.handleOperandDisallowed;

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
        fs[SUB_PARSER_WORD_UNISWAP_V3_EXACT_OUTPUT] = uniswapV3ExactOutputSubParser;
        fs[SUB_PARSER_WORD_UNISWAP_V3_EXACT_INPUT] = uniswapV3ExactInputSubParser;
        fs[SUB_PARSER_WORD_UNISWAP_V3_TWAP] = uniswapV3TwapSubParser;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the amount in opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2AmountInSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V2_AMOUNT_IN
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the amount out opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2AmountOutSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V2_AMOUNT_OUT
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the quote opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV2QuoteSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V2_QUOTE
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the exact output opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV3ExactOutputSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V3_EXACT_OUTPUT
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the exact input opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV3ExactInputSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V3_EXACT_INPUT
        );
    }

    /// Thin wrapper around LibSubParse.subParserExtern that provides the extern
    /// address and index of the TWAP opcode index in the extern.
    //slither-disable-next-line dead-code
    function uniswapV3TwapSubParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()), constantsHeight, ioByte, operand, OPCODE_UNISWAP_V3_TWAP
        );
    }
}
