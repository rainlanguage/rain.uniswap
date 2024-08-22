// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibUniswapV2} from "../../lib/v2/LibUniswapV2.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {FIXED_POINT_ONE} from "rain.math.fixedpoint/lib/FixedPointDecimalConstants.sol";
import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

/// @title LibOpUniswapV2AmountOut
/// @notice Opcode to calculate the amount out for a Uniswap V2 pair.
library LibOpUniswapV2AmountOut {
    /// Extern integrity for the process of calculating the amount out for a
    /// Uniswap V2 pair. Always requires 5 inputs and produces 1 or 2 outputs.
    //slither-disable-next-line dead-code
    function integrityUniswapV2AmountOut(Operand operand, uint256, uint256) internal pure returns (uint256, uint256) {
        unchecked {
            // Outputs is 1 if we don't want the timestamp (operand 0) or 2 if we
            // do (operand 1).
            uint256 outputs = 1 + (Operand.unwrap(operand) & 1);
            return (5, outputs);
        }
    }

    //slither-disable-next-line dead-code
    function runUniswapV2AmountOut(Operand operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 amountOut;
        uint256 reserveTimestamp;
        uint256 withTime;

        {
            uint256 tokenIn;
            uint256 tokenOut;
            uint256 amountIn;
            uint256 v2Factory;
            uint256 initCodeHash;
            assembly ("memory-safe") {
                tokenIn := mload(add(inputs, 0x20))
                tokenOut := mload(add(inputs, 0x40))
                amountIn := mload(add(inputs, 0x60))
                v2Factory := mload(add(inputs, 0x80))
                initCodeHash := mload(add(inputs, 0xa0))
                withTime := and(operand, 1)
            }
            address tokenInAddress = address(uint160(tokenIn));
            address tokenOutAddress = address(uint160(tokenOut));

            // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
            uint256 tokenInDecimals = IERC20Metadata(tokenInAddress).decimals();

            (amountOut, reserveTimestamp) = LibUniswapV2.getAmountOutByTokenWithTime(
                address(uint160(v2Factory)),
                bytes32(initCodeHash),
                tokenInAddress,
                tokenOutAddress,
                // Default of erroring on overflow is safest as saturating will lose
                // precision.
                // Default rounding down.
                LibFixedPointDecimalScale.scaleN(amountIn, tokenInDecimals, 0)
            );

            // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
            uint256 tokenOutDecimals = IERC20Metadata(tokenOutAddress).decimals();
            amountOut = LibFixedPointDecimalScale.scale18(amountOut, tokenOutDecimals, 0);
        }

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
    //     uint256 amountIn = inputs[1];
    //     uint256 tokenIn = inputs[2];
    //     uint256 tokenOut = inputs[3];
    //     (uint256 amountOut, uint256 reserveTimestamp) = LibUniswapV2.getAmountOutByTokenWithTime(
    //         address(uint160(factory)), address(uint160(tokenIn)), address(uint160(tokenOut)), amountIn
    //     );
    //     outputs = new uint256[](1 + (Operand.unwrap(operand) & 1));
    //     outputs[0] = amountOut;
    //     if (Operand.unwrap(operand) & 1 == 1) outputs[1] = reserveTimestamp;
    // }
}
