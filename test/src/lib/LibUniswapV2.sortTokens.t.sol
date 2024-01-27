// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUniswapV2ReferenceTest} from "test/abstract/LibUniswapV2ReferenceTest.sol";
import {LibUniswapV2} from "src/lib/LibUniswapV2.sol";
import {UniswapV2IdenticalAddresses, UniswapV2ZeroAddress} from "src/error/ErrUniswapV2.sol";

contract LibUniswapV2SortTokensTest is LibUniswapV2ReferenceTest {
    /// Expose the internal sortTokens function for testing so we can expect
    /// reverts.
    function externalSortTokens(address tokenA, address tokenB)
        external
        pure
        returns (address token0, address token1)
    {
        return LibUniswapV2.sortTokens(tokenA, tokenB);
    }

    /// As long as the token addresses are not equal to each other or 0, the
    /// two implementations should not revert and should return the same output.
    function testSortTokensHappy(address tokenA, address tokenB) external {
        vm.assume(tokenA != tokenB);
        vm.assume(tokenA != address(0));
        vm.assume(tokenB != address(0));

        (address token0, address token1) = LibUniswapV2.sortTokens(tokenA, tokenB);
        (address referenceToken0, address referenceToken1) = iReferenceLib.sortTokens(tokenA, tokenB);

        assertEq(token0, referenceToken0);
        assertEq(token1, referenceToken1);
    }

    /// When the token addresses are equal to each other, the two implementations
    /// should both revert.
    function testSortTokensEqual(address token) external {
        vm.assume(token != address(0));

        vm.expectRevert("UniswapV2Library: IDENTICAL_ADDRESSES");
        iReferenceLib.sortTokens(token, token);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2IdenticalAddresses.selector));
        LibUniswapV2SortTokensTest(address(this)).externalSortTokens(token, token);
    }

    /// When token A is the zero address, the two implementations should both
    /// revert.
    function testSortTokensZeroAddressA(address tokenB) external {
        vm.assume(tokenB != address(0));

        vm.expectRevert("UniswapV2Library: ZERO_ADDRESS");
        iReferenceLib.sortTokens(address(0), tokenB);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAddress.selector));
        LibUniswapV2SortTokensTest(address(this)).externalSortTokens(address(0), tokenB);
    }

    /// When token B is the zero address, the two implementations should both
    /// revert.
    function testSortTokensZeroAddressB(address tokenA) external {
        vm.assume(tokenA != address(0));

        vm.expectRevert("UniswapV2Library: ZERO_ADDRESS");
        iReferenceLib.sortTokens(tokenA, address(0));

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAddress.selector));
        LibUniswapV2SortTokensTest(address(this)).externalSortTokens(tokenA, address(0));
    }
}
