// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    UniswapExtern,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    BaseRainterpreterExternNPE2
} from "../abstract/UniswapExtern.sol";
import {
    UniswapSubParser,
    SUB_PARSER_WORD_PARSERS,
    SUB_PARSER_OPERAND_HANDLERS,
    SUB_PARSER_PARSE_META,
    BaseRainterpreterSubParserNPE2,
    AuthoringMetaV2,
    authoringMetaV2
} from "../abstract/UniswapSubParser.sol";

/// @title UniswapWords
/// Simply merges the two abstract contracts into a single concrete contract.
contract UniswapWords is UniswapExtern, UniswapSubParser {
    /// @inheritdoc UniswapSubParser
    //slither-disable-next-line dead-code
    function extern() internal view override returns (address) {
        return address(this);
    }

    /// This is only needed because the parser and extern base contracts both
    /// implement IERC165, and the compiler needs to be told how to resolve the
    /// ambiguity.
    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}