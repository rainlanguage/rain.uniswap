// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IViewQuoterV3} from "../../interface/IViewQuoterV3.sol";
import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title OpUniswapV3ExactInput
/// @notice Opcode to calculate the amount in for an exact input from a Uniswap
/// V3 pair.
abstract contract OpUniswapV3ExactInput {
    function v3Quoter() internal view virtual returns (IViewQuoterV3);

    //slither-disable-next-line dead-code
    function integrityUniswapV3ExactInput(Operand, uint256, uint256) internal pure returns (uint256, uint256) {
        return (4, 1);
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

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint256 tokenInDecimals = IERC20Metadata(address(uint160(tokenIn))).decimals();

        (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate) = v3Quoter()
            .quoteExactInputSingle(
            IViewQuoterV3.QuoteExactInputSingleParams(
                address(uint160(tokenIn)),
                address(uint160(tokenOut)),
                // Default of erroring on overflow is safest as saturating will lose
                // precision.
                // Default rounding down.
                LibFixedPointDecimalScale.scaleN(amountIn, tokenInDecimals, 0),
                uint24(fee),
                // This is the sqrtPriceLimitX96, which is 0 for no limit.
                // It's not even used by the quoter contract internally.
                0
            )
        );
        (sqrtPriceX96After, initializedTicksCrossed, gasEstimate);

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint256 tokenOutDecimals = IERC20Metadata(address(uint160(tokenOut))).decimals();
        amountOut = LibFixedPointDecimalScale.scale18(amountOut, tokenOutDecimals, 0);

        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), amountOut)
        }
        return inputs;
    }
}
