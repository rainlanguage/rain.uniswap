// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "rain.interpreter/../test/util/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract UniswapWordsUniswapV3TwapTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function constructionMetaPath() internal pure override returns (string memory) {
        return string.concat("lib/rain.interpreter/", EXPRESSION_DEPLOYER_NP_META_PATH);
    }

    function testUniswapWordsUniswapV3TwapHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](11);
        // dai
        expectedStack[10] = uint256(uint160(0x6B175474E89094C44Da98b954EedeAC495271d0F));
        // wbtc
        expectedStack[9] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // weth
        expectedStack[8] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // twap current-price btc eth
        expectedStack[7] = 18357262430617394206;
        // twap last-second btc eth
        expectedStack[6] = 18355922996327998332;
        // twap 30 mins btc eth
        expectedStack[5] = 18350417320600948012;
        // twap current-price eth btc
        expectedStack[4] = 54474353339969539;
        // twap last-second eth btc
        expectedStack[3] = 54478328341214141;
        // twap 30 mins eth btc
        expectedStack[2] = 54494673474120834;
        // twap dai weth
        expectedStack[1] = 441994201059850;
        // twap weth dai
        expectedStack[0] = 2262473122050283788354;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "dai: 0x6B175474E89094C44Da98b954EedeAC495271d0F,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "current-price-btc-eth: uniswap-v3-twap(wbtc 8 weth 18 0 0 [uniswap-v3-fee-low]),",
                    "last-second-btc-eth: uniswap-v3-twap(wbtc 8 weth 18 2 1 [uniswap-v3-fee-low]),",
                    "last-30-mins-btc-eth: uniswap-v3-twap(wbtc 8 weth 18 int-mul(60 30) 0 [uniswap-v3-fee-low]),",
                    "current-price-eth-btc: uniswap-v3-twap(weth 18 wbtc 8 0 0 [uniswap-v3-fee-low]),",
                    "last-second-eth-btc: uniswap-v3-twap(weth 18 wbtc 8 2 1 [uniswap-v3-fee-low]),",
                    "last-30-mins-eth-btc: uniswap-v3-twap(weth 18 wbtc 8 int-mul(60 30) 0 [uniswap-v3-fee-low]),",
                    "weth-dai: uniswap-v3-twap(dai 18 weth 18 1000 0 [uniswap-v3-fee-low]),"
                    "dai-weth: uniswap-v3-twap(weth 18 dai 18 1000 0 [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-twap"
        );
    }
}
