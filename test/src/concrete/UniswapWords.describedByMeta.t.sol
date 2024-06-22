// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibTestFork} from "test/lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract RainterpreterExpressionDeployerNPE2DescribedByMetaV1Test is Test {
    constructor() {
        LibTestFork.forkEthereum(vm);
    }

    function testRainterpreterExpressionDeployerNPE2DescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary("meta/UniswapWords.rain.meta");
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        assertEq(keccak256(describedByMeta), uniswapWords.describedByMetaV1());
    }
}
