// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "./FullMath8x.sol";
import "./SqrtPriceMath8x.sol";

/// @title Computes the result of a swap within ticks
/// @notice Contains methods for computing the result of a swap within a single tick price range, i.e., a single tick.
library SwapMath8x {
    /// @notice Computes the result of swapping some amount in, or amount out, given the parameters of the swap
    /// @dev The fee, plus the amount in, will never exceed the amount remaining if the swap's `amountSpecified` is positive
    /// @param sqrtRatioCurrentX96 The current sqrt price of the pool
    /// @param sqrtRatioTargetX96 The price that cannot be exceeded, from which the direction of the swap is inferred
    /// @param liquidity The usable liquidity
    /// @param amountRemaining How much input or output amount is remaining to be swapped in/out
    /// @param feePips The fee taken from the input amount, expressed in hundredths of a bip
    /// @return sqrtRatioNextX96 The price after swapping the amount in/out, not to exceed the price target
    /// @return amountIn The amount to be swapped in, of either token0 or token1, based on the direction of the swap
    /// @return amountOut The amount to be received, of either token0 or token1, based on the direction of the swap
    /// @return feeAmount The amount of input that will be taken as a fee
    function computeSwapStep(
        uint160 sqrtRatioCurrentX96,
        uint160 sqrtRatioTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 feePips
    ) internal pure returns (uint160 sqrtRatioNextX96, uint256 amountIn, uint256 amountOut, uint256 feeAmount) {
        unchecked {
            bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96;
            bool exactIn = amountRemaining >= 0;

            if (exactIn) {
                uint256 amountRemainingLessFee = FullMath8x.mulDiv(uint256(amountRemaining), 1e6 - feePips, 1e6);
                amountIn = zeroForOne
                    ? SqrtPriceMath8x.getAmount0Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, true)
                    : SqrtPriceMath8x.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, true);
                if (amountRemainingLessFee >= amountIn) {
                    sqrtRatioNextX96 = sqrtRatioTargetX96;
                } else {
                    sqrtRatioNextX96 = SqrtPriceMath8x.getNextSqrtPriceFromInput(
                        sqrtRatioCurrentX96, liquidity, amountRemainingLessFee, zeroForOne
                    );
                }
            } else {
                amountOut = zeroForOne
                    ? SqrtPriceMath8x.getAmount1Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, false)
                    : SqrtPriceMath8x.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, false);
                if (uint256(-amountRemaining) >= amountOut) {
                    sqrtRatioNextX96 = sqrtRatioTargetX96;
                } else {
                    sqrtRatioNextX96 = SqrtPriceMath8x.getNextSqrtPriceFromOutput(
                        sqrtRatioCurrentX96, liquidity, uint256(-amountRemaining), zeroForOne
                    );
                }
            }

            bool max = sqrtRatioTargetX96 == sqrtRatioNextX96;

            // get the input/output amounts
            if (zeroForOne) {
                amountIn = max && exactIn
                    ? amountIn
                    : SqrtPriceMath8x.getAmount0Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, true);
                amountOut = max && !exactIn
                    ? amountOut
                    : SqrtPriceMath8x.getAmount1Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, false);
            } else {
                amountIn = max && exactIn
                    ? amountIn
                    : SqrtPriceMath8x.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, true);
                amountOut = max && !exactIn
                    ? amountOut
                    : SqrtPriceMath8x.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, false);
            }

            // cap the output amount to not exceed the remaining output amount
            if (!exactIn && amountOut > uint256(-amountRemaining)) {
                amountOut = uint256(-amountRemaining);
            }

            if (exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96) {
                // we didn't reach the target, so take the remainder of the maximum input as fee
                feeAmount = uint256(amountRemaining) - amountIn;
            } else {
                feeAmount = FullMath8x.mulDivRoundingUp(amountIn, feePips, 1e6 - feePips);
            }
        }
    }
}