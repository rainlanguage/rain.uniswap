// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {OpUniswapV2AmountOut} from "src/abstract/op/OpUniswapV2AmountOut.sol";

contract OpUniswapV2AmountOutTest is Test, OpUniswapV2AmountOut {
    function v2Factory() internal pure override returns (address) {
        return address(0);
    }

    function testIntegrity(Operand operand, uint256 inputs, uint256 outputs) external {
        (uint256 calculatedInputs, uint256 calculatedOutputs) =
            OpUniswapV2AmountOut.integrityUniswapV2AmountOut(operand, inputs, outputs);
        assertEq(calculatedInputs, 3);
        assertEq(calculatedOutputs, Operand.unwrap(operand) & 1 > 0 ? 2 : 1);
    }
}
