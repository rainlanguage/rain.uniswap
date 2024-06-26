// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {BaseRainterpreterExternNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterExternNPE2.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {LibOpUniswapV2AmountIn} from "../lib/op/LibOpUniswapV2AmountIn.sol";
import {LibOpUniswapV2AmountOut} from "../lib/op/LibOpUniswapV2AmountOut.sol";
import {LibOpUniswapV2Quote} from "../lib/op/LibOpUniswapV2Quote.sol";
import {OpUniswapV3ExactOutput} from "./op/OpUniswapV3ExactOutput.sol";
import {OpUniswapV3ExactInput} from "./op/OpUniswapV3ExactInput.sol";
import {LibOpUniswapV3Twap} from "../lib/op/LibOpUniswapV3Twap.sol";
import {IViewQuoterV3} from "../interface/IViewQuoterV3.sol";
import {INTEGRITY_FUNCTION_POINTERS, OPCODE_FUNCTION_POINTERS} from "../generated/UniswapWords.pointers.sol";

/// @dev Index into the function pointers array for the V2 amount in.
uint256 constant OPCODE_UNISWAP_V2_AMOUNT_IN = 0;
/// @dev Index into the function pointers array for the V2 amount out.
uint256 constant OPCODE_UNISWAP_V2_AMOUNT_OUT = 1;
/// @dev Index into the function pointers array for the V2 quote.
uint256 constant OPCODE_UNISWAP_V2_QUOTE = 2;
/// @dev Index into the function pointers array for the V3 exact output.
uint256 constant OPCODE_UNISWAP_V3_EXACT_OUTPUT = 3;
/// @dev Index into the function pointers array for the V3 exact input.
uint256 constant OPCODE_UNISWAP_V3_EXACT_INPUT = 4;
/// @dev Index into the function pointers array for the V3 twap.
uint256 constant OPCODE_UNISWAP_V3_TWAP = 5;
/// @dev The number of function pointers in the array.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 6;

struct UniswapExternConfig {
    address v2Factory;
    address v3Quoter;
}

/// @title UniswapExtern
/// Implements externs for Uniswap V2 and V3.
abstract contract UniswapExtern is BaseRainterpreterExternNPE2, OpUniswapV3ExactOutput, OpUniswapV3ExactInput {
    IViewQuoterV3 public immutable iV3Quoter;

    constructor(UniswapExternConfig memory config) {
        iV3Quoter = IViewQuoterV3(config.v3Quoter);
    }

    /// @inheritdoc OpUniswapV3ExactOutput
    //slither-disable-next-line dead-code
    function v3Quoter() internal view override(OpUniswapV3ExactOutput, OpUniswapV3ExactInput) returns (IViewQuoterV3) {
        return iV3Quoter;
    }

    /// @inheritdoc BaseRainterpreterExternNPE2
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    /// @inheritdoc BaseRainterpreterExternNPE2
    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    /// Create a 16-bit pointer array for the opcode function pointers. This is
    /// relatively gas inefficent so it is only called during tests to cross
    /// reference against the constant values that are used at runtime.
    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        function(Operand, uint256[] memory) internal view returns (uint256[] memory)[] memory fs = new function(Operand, uint256[] memory) internal view returns (uint256[] memory)[](
            OPCODE_FUNCTION_POINTERS_LENGTH
        );
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = LibOpUniswapV2AmountIn.runUniswapV2AmountIn;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.runUniswapV2AmountOut;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.runUniswapV2Quote;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.runUniswapV3ExactOutput;
        fs[OPCODE_UNISWAP_V3_EXACT_INPUT] = OpUniswapV3ExactInput.runUniswapV3ExactInput;
        fs[OPCODE_UNISWAP_V3_TWAP] = LibOpUniswapV3Twap.runUniswapV3Twap;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    /// Create a 16-bit pointer array for the integrity function pointers. This
    /// is relatively gas inefficent so it is only called during tests to cross
    /// reference against the constant values that are used at runtime.
    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        function(Operand, uint256, uint256) internal pure returns (uint256, uint256)[] memory fs = new function(Operand, uint256, uint256) internal pure returns (uint256, uint256)[](
            OPCODE_FUNCTION_POINTERS_LENGTH
        );
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = LibOpUniswapV2AmountIn.integrityUniswapV2AmountIn;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.integrityUniswapV2AmountOut;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.integrityUniswapV2Quote;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.integrityUniswapV3ExactOutput;
        fs[OPCODE_UNISWAP_V3_EXACT_INPUT] = OpUniswapV3ExactInput.integrityUniswapV3ExactInput;
        fs[OPCODE_UNISWAP_V3_TWAP] = LibOpUniswapV3Twap.integrityUniswapV3Twap;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }
}
