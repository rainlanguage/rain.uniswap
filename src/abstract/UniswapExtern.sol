// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {BaseRainterpreterExternNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterExternNPE2.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {OpUniswapV2AmountIn} from "./op/OpUniswapV2AmountIn.sol";
import {LibOpUniswapV2AmountOut} from "../lib/op/LibOpUniswapV2AmountOut.sol";
import {LibOpUniswapV2Quote} from "../lib/op/LibOpUniswapV2Quote.sol";
import {OpUniswapV3ExactOutput} from "./op/OpUniswapV3ExactOutput.sol";
import {OpUniswapV3ExactInput} from "./op/OpUniswapV3ExactInput.sol";
import {IViewQuoterV3} from "../interface/IViewQuoterV3.sol";

/// @dev Runtime constant form of the pointers to the integrity functions.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"10cb10db10db10eb10eb";
/// @dev Runtime constant form of the pointers to the opcode functions.
bytes constant OPCODE_FUNCTION_POINTERS = hex"0d180d8b0de40e100f2b";

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
/// @dev The number of function pointers in the array.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 5;

struct UniswapExternConfig {
    address v2Factory;
    address v3Quoter;
}

/// @title UniswapExtern
/// Implements externs for Uniswap V2 and V3.
abstract contract UniswapExtern is
    BaseRainterpreterExternNPE2,
    OpUniswapV2AmountIn,
    OpUniswapV3ExactOutput,
    OpUniswapV3ExactInput
{
    address public immutable iV2Factory;
    IViewQuoterV3 public immutable iV3Quoter;

    constructor(UniswapExternConfig memory config) {
        iV2Factory = config.v2Factory;
        iV3Quoter = IViewQuoterV3(config.v3Quoter);
    }

    /// @inheritdoc OpUniswapV2AmountIn
    //slither-disable-next-line dead-code
    function v2Factory() internal view override returns (address) {
        return iV2Factory;
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
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = OpUniswapV2AmountIn.runUniswapV2AmountIn;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.run;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.run;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.runUniswapV3ExactOutput;
        fs[OPCODE_UNISWAP_V3_EXACT_INPUT] = OpUniswapV3ExactInput.runUniswapV3ExactInput;

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
        fs[OPCODE_UNISWAP_V2_AMOUNT_IN] = OpUniswapV2AmountIn.integrityUniswapV2AmountIn;
        fs[OPCODE_UNISWAP_V2_AMOUNT_OUT] = LibOpUniswapV2AmountOut.integrity;
        fs[OPCODE_UNISWAP_V2_QUOTE] = LibOpUniswapV2Quote.integrity;
        fs[OPCODE_UNISWAP_V3_EXACT_OUTPUT] = OpUniswapV3ExactOutput.integrityUniswapV3ExactOutput;
        fs[OPCODE_UNISWAP_V3_EXACT_INPUT] = OpUniswapV3ExactInput.integrityUniswapV3ExactInput;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }
}
