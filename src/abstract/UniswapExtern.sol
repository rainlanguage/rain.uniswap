// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {BaseRainterpreterExternNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterExternNPE2.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {LibOpUniswapV2AmountIn} from "../lib/op/LibOpUniswapV2AmountIn.sol";
import {LibOpUniswapV2AmountOut} from "../lib/op/LibOpUniswapV2AmountOut.sol";
import {LibOpUniswapV2Quote} from "../lib/op/LibOpUniswapV2Quote.sol";
import {OpUniswapV3ExactOutput} from "./op/OpUniswapV3ExactOutput.sol";
import {IViewQuoterV3} from "../interface/IViewQuoterV3.sol";

/// @dev Runtime constant form of the pointers to the integrity functions.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"0ec40ec40ec40ed4";
/// @dev Runtime constant form of the pointers to the opcode functions.
bytes constant OPCODE_FUNCTION_POINTERS = hex"0bf10c4a0c760ca2";

/// @dev Index into the function pointers array for the V2 amount in.
uint256 constant OPCODE_UNISWAP_V2_AMOUNT_IN = 0;
/// @dev Index into the function pointers array for the V2 amount out.
uint256 constant OPCODE_UNISWAP_V2_AMOUNT_OUT = 1;
/// @dev Index into the function pointers array for the V2 quote.
uint256 constant OPCODE_UNISWAP_V2_QUOTE = 2;
/// @dev Index into the function pointers array for the V3 exact output.
uint256 constant OPCODE_UNISWAP_V3_EXACT_OUTPUT = 3;
/// @dev The number of function pointers in the array.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 4;

struct UniswapExternConfig {
    address quoter;
}

/// @title UniswapExtern
/// Implements externs for Uniswap V2 and V3.
abstract contract UniswapExtern is BaseRainterpreterExternNPE2, OpUniswapV3ExactOutput {
    IViewQuoterV3 public immutable iQuoter;

    constructor(UniswapExternConfig memory config) {
        iQuoter = IViewQuoterV3(config.quoter);
    }

    function quoter() internal view override returns (IViewQuoterV3) {
        return iQuoter;
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
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = LibOpUniswapV2AmountIn.run;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.run;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.run;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.run;

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
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = LibOpUniswapV2AmountIn.integrity;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.integrity;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.integrity;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.integrity;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }
}
