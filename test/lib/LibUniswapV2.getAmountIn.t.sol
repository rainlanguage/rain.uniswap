// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {stdError} from "forge-std/Test.sol";
import {LibUniswapV2ReferenceTest} from "test/util/abstract/LibUniswapV2ReferenceTest.sol";
import {LibWillOverflow} from "rain.will-overflow/src/lib/LibWillOverflow.sol";
import {LibUniswapV2} from "src/lib/LibUniswapV2.sol";
import {UniswapV2ZeroOutputAmount, UniswapV2ZeroLiquidity} from "src/error/ErrUniswapV2.sol";

contract LibUniswapV2GetAmountInTest is LibUniswapV2ReferenceTest {
    /// Expose the internal getAmountIn function for testing so we can expect
    /// reverts.
    function externalGetAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256)
    {
        return LibUniswapV2.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    /// There is a lot that can overflow in this function, but if none of it
    /// overflows the two implementations should match.
    function testGetAmountInHappy(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        // Numerator.
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, amountOut));
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn * amountOut, 1000));

        // Denominator.
        vm.assume(!LibWillOverflow.subWillOverflow(reserveOut, amountOut));
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveOut - amountOut, 997));
        vm.assume(reserveOut > amountOut);

        assertEq(
            LibUniswapV2.getAmountIn(amountOut, reserveIn, reserveOut),
            iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut)
        );
    }

    /// When the output amount is 0 getAmountIn should error.
    function testGetAmountInZeroAmount(uint256 reserveIn, uint256 reserveOut) external {
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        iReferenceLib.getAmountIn(0, reserveIn, reserveOut);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroOutputAmount.selector));
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(0, reserveIn, reserveOut);
    }

    /// When the input reserve is 0 getAmountIn should error.
    function testGetAmountInZeroReserveIn(uint256 amountOut, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.getAmountIn(amountOut, 0, reserveOut);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, 0, reserveOut);
    }

    /// When the output reserve is 0 getAmountIn should error.
    function testGetAmountInZeroReserveOut(uint256 amountOut, uint256 reserveIn) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        iReferenceLib.getAmountIn(amountOut, reserveIn, 0);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroLiquidity.selector));
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, 0);
    }

    /// If the numerator first mul overflows then both implementations will
    /// revert.
    function testGetAmountInOverflow0(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(LibWillOverflow.mulWillOverflow(reserveIn, amountOut));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, reserveOut);
    }

    /// If the numerator second mul overflows then both implementations will
    /// revert.
    function testGetAmountInOverflow1(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, amountOut));
        vm.assume(LibWillOverflow.mulWillOverflow(reserveIn * amountOut, 1000));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, reserveOut);
    }

    /// If the denominator sub overflows then both implementations will revert.
    function testGetAmountInOverflow2(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, amountOut));
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn * amountOut, 1000));
        vm.assume(LibWillOverflow.subWillOverflow(reserveOut, amountOut));

        vm.expectRevert("ds-math-sub-underflow");
        iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, reserveOut);
    }

    /// If the denominator mul overflows then both implementations will revert.
    function testGetAmountInOverflow3(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        reserveOut = bound(reserveOut, 1, type(uint256).max);
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, amountOut));
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn * amountOut, 1000));
        vm.assume(!LibWillOverflow.subWillOverflow(reserveOut, amountOut));
        vm.assume(LibWillOverflow.mulWillOverflow(reserveOut - amountOut, 997));

        vm.expectRevert("ds-math-mul-overflow");
        iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut);

        vm.expectRevert(stdError.arithmeticError);
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, reserveOut);
    }

    /// If the denominator is 0 then both implementations will revert.
    function testGetAmountInOverflow4(uint256 amountOut, uint256 reserveIn) external {
        amountOut = bound(amountOut, 1, type(uint256).max);
        reserveIn = bound(reserveIn, 1, type(uint256).max);
        uint256 reserveOut = amountOut;
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn, amountOut));
        vm.assume(!LibWillOverflow.mulWillOverflow(reserveIn * amountOut, 1000));

        // Actually hits an INVALID opcode 0xFE on the EVM.
        vm.expectRevert();
        iReferenceLib.getAmountIn(amountOut, reserveIn, reserveOut);

        vm.expectRevert(stdError.divisionError);
        LibUniswapV2GetAmountInTest(address(this)).externalGetAmountIn(amountOut, reserveIn, reserveOut);
    }
}
