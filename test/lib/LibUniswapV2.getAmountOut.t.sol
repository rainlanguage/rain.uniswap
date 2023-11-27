// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {stdError} from "forge-std/Test.sol";
import {LibUniswapV2ReferenceTest} from "test/util/abstract/LibUniswapV2ReferenceTest.sol";
import {LibWillOverflow} from "rain.will-overflow/src/lib/LibWillOverflow.sol";
import {LibUniswapV2} from "src/lib/LibUniswapV2.sol";
import {UniswapV2ZeroInputAmount, UniswapV2ZeroLiquidity} from "src/error/ErrUniswapV2.sol";

contract LibUniswapV2GetAmountOutTest is LibUniswapV2ReferenceTest {
    /// Expose the internal getAmountOut function for testing so we can expect
    /// reverts.
    function externalGetAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256)
    {
        return LibUniswapV2.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    /// There is a lot that can overflow in this function, but if none of it
    /// overflows the two implementations should match.
    function testGetAmountOutHappy(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        // Amount in with fee.
        vm.assume(!LibWillOverflow.mulWillOverflow(amountIn, 997));
        uint256 amountInWithFee = amountIn * 997;
        // Numerator.
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveOut, amountInWithFee));
        // Denominator.
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, 1000));
        uint256 reserveInScaled = reserveIn * 1000;
        vm.assume(!LibWillOverflow.addWillOverflow(reserveInScaled, amountInWithFee));

        assertEq(
            LibUniswapV2.getAmountOut(amountIn, reserveIn, reserveOut),
            iReferenceLib.getAmountOut(amountIn, reserveIn, reserveOut)
        );
    }

    /// When the input amount is 0 getAmountOut should error.
    function testGetAmountOutZeroAmount(uint256 reserveIn, uint256 reserveOut) external {
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        iReferenceLib.getAmountOut(0, reserveIn, reserveOut);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroInputAmount.selector));
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(0, reserveIn, reserveOut);
    }

    /// When the input reserve is 0 getAmountOut should error.
    function testGetAmountOutZeroReserveIn(uint256 amountIn, uint256 reserveOut) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.getAmountOut(amountIn, 0, reserveOut);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, 0, reserveOut);
    }

    /// When the output reserve is 0 getAmountOut should error.
    function testGetAmountOutZeroReserveOut(uint256 amountIn, uint256 reserveIn) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.getAmountOut(amountIn, reserveIn, 0);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, reserveIn, 0);
    }

    /// If the amountInWithFee mul overflows then both implementations will
    /// revert.
    function testGetAmountOutOverflow0(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(LibWillOverflow.mulWillOverflow(amountIn, 997));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountOut(amountIn, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, reserveIn, reserveOut);
    }

    /// If the numerator mul overflows then both implementations will revert.
    function testGetAmountOutOverflow1(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(amountIn, 997));
        uint256 amountInWithFee = amountIn * 997;
        vm.assume(LibWillOverflow.mulWillOverflow(reserveOut, amountInWithFee));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountOut(amountIn, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, reserveIn, reserveOut);
    }

    /// If the reserveIn scaling mul overflows then both implementations will
    /// revert.
    function testGetAmountOutOverflow2(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external {
        amountIn = bound(amountIn, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(amountIn, 997));
        uint256 amountInWithFee = amountIn * 997;
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveOut, amountInWithFee));
        vm.assume(LibWillOverflow.mulWillOverflow(reserveIn, 1000));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountOut(amountIn, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, reserveIn, reserveOut);
    }

    /// If the denominator add overflows then both implementations will revert.
    /// This is too intensive on the fuzzer to find values that satisfy all the
    /// assumes, so we go with a hardcoded value just to exercise the code.
    function testGetAmountOutOverflow3() external {
        uint256 amountIn = 1e74;
        uint256 reserveIn = 1e74;
        uint256 reserveOut = 1;
        assertTrue(!LibWillOverflow.mulWillOverflow(amountIn, 997), "a");
        uint256 amountInWithFee = amountIn * 997;
        assertTrue(!LibWillOverflow.mulWillOverflow(reserveOut, amountInWithFee), "b");
        assertTrue(!LibWillOverflow.mulWillOverflow(reserveIn, 1000), "c");
        uint256 reserveInScaled = reserveIn * 1000;
        assertTrue(LibWillOverflow.addWillOverflow(reserveInScaled, amountInWithFee), "d");

        vm.expectRevert("ds-math-add-overflow");
        iReferenceLib.getAmountOut(amountIn, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountOutTest(address(this)).externalGetAmountOut(amountIn, reserveIn, reserveOut);
    }
}
