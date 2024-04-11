// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibFork, BLOCK_NUMBER} from "test/lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract RainterpreterExpressionDeployerNPE2DescribedByMetaV1Test is Test {
    constructor() {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function testRainterpreterExpressionDeployerNPE2DescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary("meta/UniswapWordsDescribedByMetaV1.rain.meta");
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        assertEq(keccak256(describedByMeta), uniswapWords.describedByMetaV1());
    }
}
