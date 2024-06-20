// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {LibOpUniswapV2AmountIn} from "src/lib/op/LibOpUniswapV2AmountIn.sol";

contract LibOpUniswapV2AmountInTest is Test {
    function testIntegrity(Operand operand, uint256 inputs, uint256 outputs) external {
        (uint256 calculatedInputs, uint256 calculatedOutputs) =
            LibOpUniswapV2AmountIn.integrityUniswapV2AmountIn(operand, inputs, outputs);
        assertEq(calculatedInputs, 5);
        assertEq(calculatedOutputs, Operand.unwrap(operand) & 1 > 0 ? 2 : 1);
    }
}
