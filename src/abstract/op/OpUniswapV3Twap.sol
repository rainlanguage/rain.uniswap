// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter/interface/unstable/IInterpreterV2.sol";
import {LibUniswapV3PoolAddress} from "../../lib/v3/LibUniswapV3PoolAddress.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {LibUniswapV3TickMath} from "../../lib/v3/LibUniswapV3TickMath.sol";
import {FixedPoint96} from "v3-core/contracts/libraries/FixedPoint96.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

error UniswapV3TwapStartAfterEnd(uint256 startSecondsAgo, uint256 endSecondsAgo);
error UniswapV3TwapTokenOrder(uint256 token0, uint256 token1);
error UniswapV3TwapTokenDecimalsOverflow(address token, uint256 decimals);

/// @title OpUniswapV3Twap
/// @notice Opcode to calculate the average ratio of a token pair over a period
/// of time according to the uniswap v3 twap.
abstract contract OpUniswapV3Twap {
    function v3Factory() internal view virtual returns (address);

    //slither-disable-next-line dead-code
    function integrityUniswapV3Twap(Operand, uint256, uint256) internal pure returns (uint256, uint256) {
        return (7, 1);
    }

    //slither-disable-next-line dead-code
    function runUniswapV3Twap(Operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 token0;
        uint256 token0Decimals;
        uint256 token1;
        uint256 token1Decimals;
        uint256 startSecondsAgo;
        uint256 endSecondsAgo;
        uint256 fee;
        assembly ("memory-safe") {
            token0 := mload(add(inputs, 0x20))
            token0Decimals := mload(add(inputs, 0x40))
            token1 := mload(add(inputs, 0x60))
            token1Decimals := mload(add(inputs, 0x80))
            startSecondsAgo := mload(add(inputs, 0xa0))
            endSecondsAgo := mload(add(inputs, 0xc0))
            fee := mload(add(inputs, 0xe0))
        }

        if (startSecondsAgo < endSecondsAgo) {
            revert UniswapV3TwapStartAfterEnd(startSecondsAgo, endSecondsAgo);
        }

        IUniswapV3Pool pool = IUniswapV3Pool(
            LibUniswapV3PoolAddress.computeAddress(
                v3Factory(),
                LibUniswapV3PoolAddress.getPoolKey(address(uint160(token0)), address(uint160(token1)), uint24(fee))
            )
        );

        uint160 sqrtPriceX96;

        // Start 0 means current price.
        if (startSecondsAgo == 0) {
            (sqrtPriceX96,,,,,,) = pool.slot0();
        } else {
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = uint32(startSecondsAgo);
            secondsAgos[1] = uint32(endSecondsAgo);
            (int56[] memory tickCumulatives,) = pool.observe(secondsAgos);

            sqrtPriceX96 = LibUniswapV3TickMath.getSqrtRatioAtTick(
                int24((tickCumulatives[1] - tickCumulatives[0]) / int56(uint56(startSecondsAgo - endSecondsAgo)))
            );
        }

        // `uint256(type(uint160).max) * 1e18` doesn't overflow, so this can't
        // either.
        // We rely on the compiler to optimise the 2 ** 192 out.
        //
        // Math:
        // sqrtPriceX96 = sqrt(price) * 2 ** 96
        // => sqrtPriceX96 / 2 ** 96 = sqrt(price)
        // => (sqrtPriceX96 / 2 ** 96) ** 2 = price
        // => (sqrtPriceX96 ** 2) / (2 ** 96) ** 2 = price
        // => (sqrtPriceX96 ** 2) / (2 ** 192) = price
        //
        // The above math results in an integer ratio, so `5` literally
        // represents that the ratio is `5:1`. This is generally useless because
        // it is incapable of representing decimals. In fact, all sub-1 prices
        // are simply rounded to 0. To avoid this we multiply by 1e18, which
        // gives us 18 decimal fixed point math version of the same, such that
        // `5e18` represents `5:1` and `5e17` represents `0.5:1`.
        //
        // Note that the tokens themselves may have different decimals.
        // For example, weth has 18 decimals, while usdc has 6, which leads to
        // ratios that are 12 ooms away from 18. Normalising all ratios to 18
        // regardless of the token decimals gives us a consistent representation
        // of "price" as a ratio, even though it's useless for actual token
        // movements.
        uint256 twap = Math.mulDiv(sqrtPriceX96, uint256(sqrtPriceX96) * 1e18, 2 ** 192);

        // inverse as 18 decimal math if the token order doesn't match the
        // uniswap internal sort.
        if (token1 <= token0) {
            twap = 1e36 / twap;
        }

        // Scale the twap to 18 decimal fixed point ratio, according to each
        // token's decimals.
        {
            if (token0Decimals > uint256(uint8(type(int8).max))) {
                revert UniswapV3TwapTokenDecimalsOverflow(address(uint160(token0)), token0Decimals);
            }

            if (token1Decimals > uint256(uint8(type(int8).max))) {
                revert UniswapV3TwapTokenDecimalsOverflow(address(uint160(token1)), token1Decimals);
            }

            twap = LibFixedPointDecimalScale.scaleBy(twap, int8(uint8(token0Decimals)) - int8(uint8(token1Decimals)), 0);
        }

        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), twap)
        }
        return inputs;
    }
}
