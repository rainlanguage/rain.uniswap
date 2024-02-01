// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "rain.interpreter/../test/util/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract UniswapWordsUniswapV3ExactOutputTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function constructionMetaPath() internal pure override returns (string memory) {
        return string.concat("lib/rain.interpreter/", EXPRESSION_DEPLOYER_NP_META_PATH);
    }

    function testUniswapWordsUniswapV3ExactInputHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // amount out 1e8 wbtc weth ~18.3 as 18 decimals (eth)
        expectedStack[1] = 18345332574258529748;
        // amount out 1 weth wbtc ~0.054 btc as 8 decimals (btc)
        expectedStack[0] = 5444667;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    // 1e8 is 1 btc because of the decimals.
                    "max-amount-out-1e8-btc-weth: uniswap-v3-quote-exact-input(wbtc weth 1e8 [uniswap-v3-fee-low]),",
                    "max-amount-out-1e18-weth-btc: uniswap-v3-quote-exact-input(weth wbtc 1e18 [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-quote-exact-input wbtc weth"
        );
    }
}
