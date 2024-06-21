// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IViewQuoterV3} from "../../interface/IViewQuoterV3.sol";
import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {LibUniswapV3PoolAddress} from "../../lib/v3/LibUniswapV3PoolAddress.sol";

/// @title OpUniswapV3ExactOutput
/// @notice Opcode to calculate the amount in for an exact output from a Uniswap
/// V3 pair.
abstract contract OpUniswapV3ExactOutput {
    function v3Quoter() internal view virtual returns (IViewQuoterV3);

    //slither-disable-next-line dead-code
    function integrityUniswapV3ExactOutput(Operand, uint256, uint256) internal pure returns (uint256, uint256) {
        return (6, 1);
    }

    //slither-disable-next-line dead-code
    function runUniswapV3ExactOutput(Operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 tokenIn;
        uint256 tokenOut;
        uint256 amountOut;
        uint256 fee;
        address pool;

        {
            uint256 factory;
            uint256 initCodeHash;
            assembly ("memory-safe") {
                tokenIn := mload(add(inputs, 0x20))
                tokenOut := mload(add(inputs, 0x40))
                amountOut := mload(add(inputs, 0x60))
                factory := mload(add(inputs, 0x80))
                initCodeHash := mload(add(inputs, 0xa0))
                fee := mload(add(inputs, 0xc0))
            }
            pool = LibUniswapV3PoolAddress.computeAddress(
                address(uint160(factory)),
                bytes32(initCodeHash),
                LibUniswapV3PoolAddress.getPoolKey(address(uint160(tokenIn)), address(uint160(tokenOut)), uint24(fee))
            );
        }

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint256 tokenOutDecimals = IERC20Metadata(address(uint160(tokenOut))).decimals();

        (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate) = v3Quoter()
            .quoteExactOutputSingleWithPool(
            IViewQuoterV3.QuoteExactOutputSingleWithPoolParams({
                tokenIn: address(uint160(tokenIn)),
                tokenOut: address(uint160(tokenOut)),
                // Default of erroring on overflow is safest as saturating will lose
                // precision.
                // Default rounding down.
                amount: LibFixedPointDecimalScale.scaleN(amountOut, tokenOutDecimals, 0),
                pool: pool,
                fee: uint24(fee),
                // This is the sqrtPriceLimitX96, which is 0 for no limit.
                // It's not even used by the quoter contract internally.
                sqrtPriceLimitX96: 0
            })
        );
        (sqrtPriceX96After, initializedTicksCrossed, gasEstimate);

        // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
        uint256 tokenInDecimals = IERC20Metadata(address(uint160(tokenIn))).decimals();
        amountIn = LibFixedPointDecimalScale.scale18(amountIn, tokenInDecimals, 0);

        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), amountIn)
        }
        return inputs;
    }
}
