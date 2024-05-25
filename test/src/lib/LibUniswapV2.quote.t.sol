// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {stdError} from "forge-std/Test.sol";
import {LibUniswapV2ReferenceTest} from "test/abstract/LibUniswapV2ReferenceTest.sol";
import {LibWillOverflow} from "rain.will-overflow/src/lib/LibWillOverflow.sol";
import {LibUniswapV2} from "src/lib/v2/LibUniswapV2.sol";
import {UniswapV2ZeroAmount, UniswapV2ZeroLiquidity} from "src/error/ErrUniswapV2.sol";

contract LibUniswapV2QuoteTest is LibUniswapV2ReferenceTest {
    /// Expose the internal quote function for testing so we can expect reverts.
    function externalQuote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256) {
        return LibUniswapV2.quote(amountA, reserveA, reserveB);
    }

    /// As long as the internal mul doesn't overflow, the quote function will
    /// never overflow, and the reference implementation output will match ours.
    function testQuoteHappy(uint256 amountA, uint256 reserveA, uint256 reserveB) public {
        amountA = bound(amountA, 1, type(uint256).max);
        reserveA = bound(reserveA, 1, type(uint256).max);
        reserveB = bound(reserveB, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(amountA, reserveB));

        assertEq(LibUniswapV2.quote(amountA, reserveA, reserveB), iReferenceLib.quote(amountA, reserveA, reserveB));
    }

    /// When the amount is 0 quotes should error.
    function testQuoteZeroAmount(uint256 reserveA, uint256 reserveB) public {
        reserveA = bound(reserveA, 1, type(uint256).max);
        reserveB = bound(reserveB, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_AMOUNT");
        iReferenceLib.quote(0, reserveA, reserveB);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAmount.selector));
        LibUniswapV2QuoteTest(address(this)).externalQuote(0, reserveA, reserveB);
    }

    /// When reserve A is 0 quotes should error.
    function testQuoteZeroReserveA(uint256 amountA, uint256 reserveB) public {
        amountA = bound(amountA, 1, type(uint256).max);
        reserveB = bound(reserveB, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(amountA, reserveB));

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.quote(amountA, 0, reserveB);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2QuoteTest(address(this)).externalQuote(amountA, 0, reserveB);
    }

    /// When reserve B is 0 quotes should error.
    function testQuoteZeroReserveB(uint256 amountA, uint256 reserveA) public {
        amountA = bound(amountA, 1, type(uint256).max);
        reserveA = bound(reserveA, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.quote(amountA, reserveA, 0);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2QuoteTest(address(this)).externalQuote(amountA, reserveA, 0);
    }

    /// If the internal mul does overflow then both implementations will revert.
    function testQuoteOverflow(uint256 amountA, uint256 reserveA, uint256 reserveB) public {
        amountA = bound(amountA, 1, type(uint256).max);
        reserveA = bound(reserveA, 1, type(uint256).max);
        reserveB = bound(reserveB, 1, type(uint256).max);
        vm.assume(LibWillOverflow.mulWillOverflow(amountA, reserveB));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.quote(amountA, reserveA, reserveB);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2QuoteTest(address(this)).externalQuote(amountA, reserveA, reserveB);
    }
}
