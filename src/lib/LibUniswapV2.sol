// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IUniswapV2Pair} from "../interface/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "../interface/IUniswapV2Factory.sol";
import {
    UniswapV2ZeroAmount,
    UniswapV2ZeroOutputAmount,
    UniswapV2IdenticalAddresses,
    UniswapV2ZeroAddress,
    UniswapV2ZeroLiquidity,
    UniswapV2ZeroInputAmount
} from "../error/ErrUniswapV2.sol";

/// UniswapV2Library from uniswap/v2-periphery is compiled with a version of
/// SafeMath that is locked to Solidity 0.6.x which means we can't use it in
/// Solidity 0.8.x. This is a copy of the library with the SafeMath dependency
/// removed, using Solidity's built-in overflow checking.
/// Some minor modifications have been made to the reference functions. These
/// are noted in the comments and/or made explicit by descriptively renaming the
/// functions to differentiate them from the original.
library LibUniswapV2 {
    /// Copy of UniswapV2Library.sortTokens for solidity 0.8.x support.
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        if (tokenA == tokenB) {
            revert UniswapV2IdenticalAddresses();
        }
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) {
            revert UniswapV2ZeroAddress();
        }
    }

    /// Copy of UniswapV2Library.pairFor for solidity 0.8.x support.
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    /// UniswapV2Library.sol has a `getReserves` function but it discards the
    /// timestamp that the pair reserves were last updated at. This function
    /// duplicates the logic of `getReserves` but returns the timestamp as well.
    function getReservesWithTime(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB, uint256 timestamp)
    {
        (address token0,) = sortTokens(tokenA, tokenB);
        // Reference implementation uses `pairFor` but for some reason this
        // doesn't seem to work on sushi's factory. Using `getPair` instead.
        // @todo investigate the discrepency.
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB, timestamp) =
            tokenA == token0 ? (reserve0, reserve1, blockTimestampLast) : (reserve1, reserve0, blockTimestampLast);
    }

    /// Copy of UniswapV2Library.getAmountIn for solidity 0.8.x support.
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        if (amountOut == 0) {
            revert UniswapV2ZeroOutputAmount();
        }
        if (reserveIn == 0 || reserveOut == 0) {
            revert UniswapV2ZeroLiquidity();
        }
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    /// Copy of UniswapV2Library.getAmountOut for solidity 0.8.x support.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        if (amountIn == 0) {
            revert UniswapV2ZeroInputAmount();
        }
        if (reserveIn == 0 || reserveOut == 0) {
            revert UniswapV2ZeroLiquidity();
        }

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /// Copy of UniswapV2Library.quote for solidity 0.8.x support.
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        if (amountA == 0) {
            revert UniswapV2ZeroAmount();
        }
        if (reserveA == 0 || reserveB == 0) {
            revert UniswapV2ZeroLiquidity();
        }
        amountB = (amountA * reserveB) / reserveA;
    }

    /// Bundles the key library logic together to produce amounts based on tokens
    /// and amounts out rather than needing to handle reserves directly.
    /// Also maps 0 amountOut to 0 amountIn unconditionally, which is different
    /// to the reference implementation.
    function getAmountInByTokenWithTime(address factory, address tokenIn, address tokenOut, uint256 amountOut)
        internal
        view
        returns (uint256 amountIn, uint256 timestamp)
    {
        (uint256 reserveIn, uint256 reserveOut, uint256 reserveTimestamp) =
            getReservesWithTime(factory, tokenIn, tokenOut);
        // Perform the 0 amountOut to 0 amountIn mapping after getting the
        // reserves so that we still error on invalid reserves.
        amountIn = amountOut == 0 ? 0 : getAmountIn(amountOut, reserveIn, reserveOut);
        timestamp = reserveTimestamp;
    }

    /// Bundles the key library logic together to produce amounts based on tokens
    /// and amounts in rather than needing to handle reserves directly.
    /// Also maps 0 amountIn to 0 amountOut unconditionally, which is different
    /// to the reference implementation.
    function getAmountOutByTokenWithTime(address factory, address tokenIn, address tokenOut, uint256 amountIn)
        internal
        view
        returns (uint256 amountOut, uint256 timestamp)
    {
        (uint256 reserveIn, uint256 reserveOut, uint256 reserveTimestamp) =
            getReservesWithTime(factory, tokenIn, tokenOut);
        // Perform the 0 amountIn to 0 amountOut mapping after getting the
        // reserves so that we still error on invalid reserves.
        amountOut = amountIn == 0 ? 0 : getAmountOut(amountIn, reserveIn, reserveOut);
        timestamp = reserveTimestamp;
    }

    /// Bundles the key library logic together to produce amounts based on tokens
    /// and amounts out rather than needing to handle reserves directly.
    /// Also maps 0 amountOut to 0 amountIn unconditionally, which is different
    /// to the reference implementation.
    function getQuoteWithTime(address factory, address tokenA, address tokenB, uint256 amountA)
        internal
        view
        returns (uint256 amountB, uint256 timestamp)
    {
        (uint256 reserveA, uint256 reserveB, uint256 reserveTimestamp) = getReservesWithTime(factory, tokenA, tokenB);
        // Perform the 0 amountOut to 0 amountIn mapping after getting the
        // reserves so that we still error on invalid reserves.
        amountB = amountA == 0 ? 0 : quote(amountA, reserveA, reserveB);
        timestamp = reserveTimestamp;
    }
}
