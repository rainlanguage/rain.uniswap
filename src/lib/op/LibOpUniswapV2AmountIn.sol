// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter/interface/unstable/IInterpreterV2.sol";
import {LibUniswapV2} from "rain.uniswapv2/src/lib/LibUniswapV2.sol";

/// @title LibOpUniswapV2AmountIn
/// @notice Opcode to calculate the amount in for a Uniswap V2 pair.
library LibOpUniswapV2AmountIn {
    /// Extern integrity for the process of calculating the amount in for a
    /// Uniswap V2 pair. Always requires 4 inputs and produces 1 or 2 outputs.
    function integrity(Operand operand, uint256, uint256) internal pure returns (uint256, uint256) {
        unchecked {
            // Outputs is 1 if we don't want the timestamp (operand 0) or 2 if we
            // do (operand 1).
            uint256 outputs = 1 + (Operand.unwrap(operand) & 1);
            return (4, outputs);
        }
    }

    function run(Operand operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 factory;
        uint256 amountOut;
        uint256 tokenIn;
        uint256 tokenOut;
        uint256 withTime;
        assembly ("memory-safe") {
            factory := mload(add(inputs, 0x20))
            amountOut := mload(add(inputs, 0x40))
            tokenIn := mload(add(inputs, 0x60))
            tokenOut := mload(add(inputs, 0x80))
            withTime := and(operand, 1)
        }
        (uint256 amountIn, uint256 reserveTimestamp) = LibUniswapV2.getAmountInByTokenWithTime(
            address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountOut
        );

        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), amountIn)
            if withTime {
                mstore(inputs, 2)
                mstore(add(inputs, 0x40), reserveTimestamp)
            }
        }
        return inputs;
    }

    // function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
    //     internal
    //     view
    //     returns (uint256[] memory outputs)
    // {
    //     uint256 factory = inputs[0];
    //     uint256 amountOut = inputs[1];
    //     uint256 tokenIn = inputs[2];
    //     uint256 tokenOut = inputs[3];
    //     (uint256 amountIn, uint256 reserveTimestamp) = LibUniswapV2.getAmountInByTokenWithTime(
    //         address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountOut
    //     );
    //     outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
    //     outputs[0] = amountIn;
    //     if (Operand.unwrap(operand) & 1 == 1) outputs[1] = reserveTimestamp;
    // }
}