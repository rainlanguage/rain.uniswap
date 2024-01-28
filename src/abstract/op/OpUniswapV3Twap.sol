// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter/interface/unstable/IInterpreterV2.sol";
import {LibUniswapV3PoolAddress} from "../../lib/v3/LibUniswapV3PoolAddress.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {LibUniswapV3TickMath} from "../../lib/v3/LibUniswapV3TickMath.sol";
import {FixedPoint96} from "v3-core/contracts/libraries/FixedPoint96.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

import {console2} from "forge-std/console2.sol";

error UniswapV3TwapStartAfterEnd(uint256 startSecondsAgo, uint256 endSecondsAgo);

/// @title OpUniswapV3Twap
/// @notice Opcode to calculate the average ratio of a token pair over a period
/// of time according to the uniswap v3 twap.
abstract contract OpUniswapV3Twap {
    function v3Factory() internal view virtual returns (address);

    //slither-disable-next-line dead-code
    function integrityUniswapV3Twap(Operand, uint256, uint256) internal pure returns (uint256, uint256) {
        return (5, 1);
    }

    //slither-disable-next-line dead-code
    function runUniswapV3Twap(Operand, uint256[] memory inputs) internal view returns (uint256[] memory) {
        uint256 tokenIn;
        uint256 tokenOut;
        uint256 startSecondsAgo;
        uint256 endSecondsAgo;
        uint256 fee;
        assembly ("memory-safe") {
            tokenIn := mload(add(inputs, 0x20))
            tokenOut := mload(add(inputs, 0x40))
            startSecondsAgo := mload(add(inputs, 0x60))
            endSecondsAgo := mload(add(inputs, 0x80))
            fee := mload(add(inputs, 0xa0))
        }

        if (startSecondsAgo < endSecondsAgo) {
            revert UniswapV3TwapStartAfterEnd(startSecondsAgo, endSecondsAgo);
        }

        IUniswapV3Pool pool = IUniswapV3Pool(
            LibUniswapV3PoolAddress.computeAddress(
                v3Factory(),
                LibUniswapV3PoolAddress.getPoolKey(address(uint160(tokenIn)), address(uint160(tokenOut)), uint24(fee))
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

        uint256 twap = Math.mulDiv(sqrtPriceX96, sqrtPriceX96, 2 ** 192);

        assembly ("memory-safe") {
            mstore(inputs, 1)
            mstore(add(inputs, 0x20), twap)
        }
        return inputs;
    }
}
