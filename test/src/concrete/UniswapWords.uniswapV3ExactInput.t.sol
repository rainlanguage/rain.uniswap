// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "rain.interpreter/../test/util/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, QUOTER, LibFork} from "../../lib/LibTestFork.sol";

contract UniswapWordsUniswapV3ExactOutputTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function constructionMetaPath() internal pure override returns (string memory) {
        return string.concat("lib/rain.interpreter/", EXPRESSION_DEPLOYER_NP_META_PATH);
    }

    function testUniswapWordsUniswapV3ExactOutputHappyFork() external {
        UniswapWords uniswapWords = new UniswapWords(UniswapExternConfig(QUOTER));

        uint256[] memory expectedStack = new uint256[](3);
        // input
        // wbtc
        expectedStack[2] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[1] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // amount out
        expectedStack[0] = 18345332574258529748;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    // 1e8 is 1 btc because of the decimals.
                    "amount-out: uniswap-v3-exact-input(wbtc weth 1e8 [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-exact-input wbtc weth"
        );
    }
}
