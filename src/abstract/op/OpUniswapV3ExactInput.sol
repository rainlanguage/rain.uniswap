// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter/interface/unstable/IInterpreterV2.sol";
import {IViewQuoterV3} from "../../interface/IViewQuoterV3.sol";

/// @title OpUniswapV3ExactInput
/// @notice Opcode to calculate the amount in for an exact input from a Uniswap
/// V3 pair.
abstract contract OpUniswapV3ExactInput {
    function quoter() internal view virtual returns (IViewQuoterV3);

    //slither-disable-next-line dead-code
    function integrityUniswapV3ExactInput(Operand, uint256, uint256) internal pure returns (uint256, uint256) {
        unchecked {
            return (4, 1);
        }
    }

    //slither-disable-next-line dead-code
    function runUniswapV3ExactInput(Operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 tokenIn;
        uint256 tokenOut;
        uint256 amountIn;
        uint256 fee;
        assembly ("memory-safe") {
            tokenIn := mload(add(inputs, 0x20))
            tokenOut := mload(add(inputs, 0x40))
            amountIn := mload(add(inputs, 0x60))
            fee := mload(add(inputs, 0x80))
        }
        (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate) = quoter()
            .quoteExactInputSingle(
            IViewQuoterV3.QuoteExactInputSingleParams(
                address(uint160(tokenIn)),
                address(uint160(tokenOut)),
                amountIn,
                uint24(fee),
                // This is the sqrtPriceLimitX96, which is 0 for no limit.
                // It's not even used by the quoter contract internally.
                0
            )
        );
        (sqrtPriceX96After, initializedTicksCrossed, gasEstimate);
        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), amountOut)
        }
        return inputs;
    }
}
