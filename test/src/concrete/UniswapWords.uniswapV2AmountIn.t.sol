// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "rain.interpreter/../test/util/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";

contract UniswapWordsUniswapV2AmountInTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function constructionMetaPath() internal pure override returns (string memory) {
        return string.concat("lib/rain.interpreter/", EXPRESSION_DEPLOYER_NP_META_PATH);
    }

    function testUniswapWordsUniswapV2AmountInHappyFork() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(address(0)));

        uint256[] memory expectedStack = new uint256[](5);
        // v2 factory
        expectedStack[4] = uint256(uint160(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f));
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // amount in
        // wbtc has 8 decimals and weth has 18 so the amount in looks very small.
        expectedStack[1] = 5460125;
        // timestamp
        expectedStack[0] = 1706347127;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "v2-factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "amount-in timestamp: uniswap-v2-amount-in<1>(v2-factory 1e18 wbtc weth);"
                )
            ),
            expectedStack,
            "uniswap-v2-amount-in wbtc weth"
        );
    }
}
