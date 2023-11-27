pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibUniswapV2} from "src/lib/LibUniswapV2.sol";
import {IUniswapV2LibraryConcrete} from "reference/src/interface/IUniswapV2LibraryConcrete.sol";

contract LibUniswapV2Test is Test {
    function testQuote(uint256 amountA, uint256 reserveA, uint256 reserveB) public {
        amountA = bound(amountA, 1, type(uint112).max);
        reserveA = bound(reserveA, 1, type(uint112).max);
        reserveB = bound(reserveB, 1, type(uint112).max);
        bytes memory referenceLibCode = vm.getCode("reference/UniswapV2LibraryConcrete.sol:UniswapV2LibraryConcrete");
        IUniswapV2LibraryConcrete referenceLib;
        assembly ("memory-safe") {
            referenceLib := create(0, add(referenceLibCode, 0x20), mload(referenceLibCode))
        }

        assertEq(
            LibUniswapV2.quote(amountA, reserveA, reserveB),
            referenceLib.quote(amountA, reserveA, reserveB),
            "quote"
        );
    }
}