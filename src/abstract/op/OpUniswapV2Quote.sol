// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {LibUniswapV2} from "../../lib/v2/LibUniswapV2.sol";
import {LibFixedPointDecimalScale, DECIMAL_MAX_SAFE_INT} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {FIXED_POINT_ONE} from "rain.math.fixedpoint/lib/FixedPointDecimalConstants.sol";

error UniswapV2TwapTokenDecimalsOverflow(address token, uint256 decimals);
error UniswapV2TwapTokenOrder(uint256 tokenIn, uint256 tokenOut);

/// @title OpUniswapV2Quote
/// @notice Opcode to calculate the quote for a Uniswap V2 pair.
abstract contract OpUniswapV2Quote {
    function v2Factory() internal view virtual returns (address);

    /// Extern integrity for the process of calculating the quote for a Uniswap
    /// V2 pair. Always requires 2 inputs and produces 1 or 2 outputs.
    //slither-disable-next-line dead-code
    function integrityUniswapV2Quote(Operand operand, uint256, uint256) internal pure returns (uint256, uint256) {
        unchecked {
            // Outputs is 1 if we don't want the timestamp (operand 0) or 2 if we
            // do (operand 1).
            uint256 outputs = 1 + (Operand.unwrap(operand) & 1);
            return (2, outputs);
        }
    }

    //slither-disable-next-line dead-code
    function runUniswapV2Quote(Operand operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 tokenIn;
        uint256 tokenOut;
        uint256 withTime;
        assembly ("memory-safe") {
            tokenIn := mload(add(inputs, 0x20))
            tokenOut := mload(add(inputs, 0x40))
            withTime := and(operand, 1)
        }
        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint256 tokenInDecimals = IERC20Metadata(address(uint160(tokenIn))).decimals();
        uint256 tokenOutDecimals = IERC20Metadata(address(uint160(tokenOut))).decimals();

        // The output ratio is the amount of tokenOut per tokenIn. If we get a
        // quote for 1e18 tokenIn, the amount out is the 18 decimal ratio.
        //
        // However, the two tokens may have significantly different decimals. If
        // we only ask for 1e18, and the decimals are very different, we'll end
        // up with precision loss when we rescale the output ratio below. By
        // asking for 1e36, we can rescale the output ratio to 18 decimals
        // then divide by 1e18 to get the correct amount out with full precision.
        (uint256 amountOut, uint256 reserveTimestamp) =
            LibUniswapV2.getQuoteWithTime(v2Factory(), address(uint160(tokenIn)), address(uint160(tokenOut)), 1e36);

        // Scale the amountOut to 18 decimal fixed point ratio, according to each
        // token's decimals.
        {
            if (tokenInDecimals > uint256(uint8(type(int8).max))) {
                revert UniswapV2TwapTokenDecimalsOverflow(address(uint160(tokenIn)), tokenInDecimals);
            }

            if (tokenOutDecimals > uint256(uint8(type(int8).max))) {
                revert UniswapV2TwapTokenDecimalsOverflow(address(uint160(tokenOut)), tokenOutDecimals);
            }

            amountOut = LibFixedPointDecimalScale.scaleBy(
                amountOut, int8(uint8(tokenInDecimals)) - int8(uint8(tokenOutDecimals)), 0
            );
        }

        amountOut /= 1e18;

        uint256 fixedPointOne = FIXED_POINT_ONE;
        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), amountOut)
            if withTime {
                mstore(inputs, 2)
                mstore(add(inputs, 0x40), mul(reserveTimestamp, fixedPointOne))
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
    //     uint256 amountA = inputs[1];
    //     uint256 tokenA = inputs[2];
    //     uint256 tokenB = inputs[3];
    //     (uint256 amountB, uint256 reserveTimestamp) = LibUniswapV2.getQuoteWithTime(
    //         address(uint160(factory)), address(uint160(tokenA)), address(uint160(tokenB)), amountA
    //     );
    //     outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
    //     outputs[0] = amountB;
    //     if (Operand.unwrap(operand) & 1 == 1) {
    //         outputs[1] = reserveTimestamp;
    //     }
    // }
}
