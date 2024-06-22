// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibUniswapV2, UNISWAP_V2_INIT_CODE_HASH} from "src/lib/v2/LibUniswapV2.sol";
import {LibUniswapV2ReferenceTest} from "test/abstract/LibUniswapV2ReferenceTest.sol";
import {UniswapV2IdenticalAddresses, UniswapV2ZeroAddress} from "src/error/ErrUniswapV2.sol";

contract LibUniswapV2PairForTest is LibUniswapV2ReferenceTest {
    /// Expose the internal pairFor function for testing so we can expect
    /// reverts.
    function externalPairFor(address factory, bytes32 initCodeHash, address tokenA, address tokenB)
        external
        pure
        returns (address pair)
    {
        return LibUniswapV2.pairFor(factory, initCodeHash, tokenA, tokenB);
    }

    /// As long as the token addresses are not equal to each other or 0, the
    /// two implementations should not revert and should return the same output.
    function testPairForHappy(address factory, address tokenA, address tokenB) external {
        vm.assume(tokenA != tokenB);
        vm.assume(tokenA != address(0));
        vm.assume(tokenB != address(0));

        assertEq(
            LibUniswapV2.pairFor(factory, UNISWAP_V2_INIT_CODE_HASH, tokenA, tokenB),
            iReferenceLib.pairFor(factory, tokenA, tokenB)
        );
    }

    /// When the token addresses are equal to each other, the two implementations
    /// should both revert.
    function testPairForEqual(address factory, bytes32 initCodeHash, address token) external {
        vm.assume(token != address(0));

        vm.expectRevert("UniswapV2Library: IDENTICAL_ADDRESSES");
        iReferenceLib.pairFor(factory, token, token);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2IdenticalAddresses.selector));
        LibUniswapV2PairForTest(address(this)).externalPairFor(factory, initCodeHash, token, token);
    }

    /// When token A is the zero address, the two implementations should both
    /// revert.
    function testPairForZeroAddressA(address factory, bytes32 initCodeHash, address tokenB) external {
        vm.assume(tokenB != address(0));

        vm.expectRevert("UniswapV2Library: ZERO_ADDRESS");
        iReferenceLib.pairFor(factory, address(0), tokenB);

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAddress.selector));
        LibUniswapV2PairForTest(address(this)).externalPairFor(factory, initCodeHash, address(0), tokenB);
    }

    /// When token B is the zero address, the two implementations should both
    /// revert.
    function testPairForZeroAddressB(address factory, bytes32 initCodeHash, address tokenA) external {
        vm.assume(tokenA != address(0));

        vm.expectRevert("UniswapV2Library: ZERO_ADDRESS");
        iReferenceLib.pairFor(factory, tokenA, address(0));

        vm.expectRevert(abi.encodeWithSelector(UniswapV2ZeroAddress.selector));
        LibUniswapV2PairForTest(address(this)).externalPairFor(factory, initCodeHash, tokenA, address(0));
    }
}
