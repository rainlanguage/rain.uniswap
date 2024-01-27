// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {Operand} from "rain.interpreter/interface/unstable/IInterpreterV2.sol";
import {LibOpUniswapV2AmountOut} from "src/lib/op/LibOpUniswapV2AmountOut.sol";

contract LibOpUniswapV2AmountOutTest is Test {
    function testIntegrity(Operand operand, uint256 inputs, uint256 outputs) external {
        (uint256 calculatedInputs, uint256 calculatedOutputs) =
            LibOpUniswapV2AmountOut.integrity(operand, inputs, outputs);
        assertEq(calculatedInputs, 4);
        assertEq(calculatedOutputs, Operand.unwrap(operand) & 1 > 0 ? 2 : 1);
    }
}
