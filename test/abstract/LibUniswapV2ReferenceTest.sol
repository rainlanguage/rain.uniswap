// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {IUniswapV2LibraryConcrete} from "reference/src/interface/IUniswapV2LibraryConcrete.sol";

abstract contract LibUniswapV2ReferenceTest is Test {
    IUniswapV2LibraryConcrete iReferenceLib;

    constructor() {
        bytes memory referenceLibCode =
            vm.getCode("out/reference/UniswapV2LibraryConcrete.sol:UniswapV2LibraryConcrete");
        IUniswapV2LibraryConcrete referenceLib;
        assembly ("memory-safe") {
            referenceLib := create(0, add(referenceLibCode, 0x20), mload(referenceLibCode))
        }
        iReferenceLib = referenceLib;
    }
}
