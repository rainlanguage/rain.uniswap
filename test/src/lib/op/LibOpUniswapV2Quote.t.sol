// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {LibOpUniswapV2Quote} from "src/lib/op/LibOpUniswapV2Quote.sol";

contract LibOpUniswapV2QuoteTest is Test {
    function testIntegrity(Operand operand, uint256 inputs, uint256 outputs) external {
        (uint256 calculatedInputs, uint256 calculatedOutputs) =
            LibOpUniswapV2Quote.integrityUniswapV2Quote(operand, inputs, outputs);
        assertEq(calculatedInputs, 4);
        assertEq(calculatedOutputs, Operand.unwrap(operand) & 1 > 0 ? 2 : 1);
    }
}
