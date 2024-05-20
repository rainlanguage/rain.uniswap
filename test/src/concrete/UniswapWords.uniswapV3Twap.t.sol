// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract UniswapWordsUniswapV3TwapTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
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
        expectedStack[7] = 18.357262430617394206e18;
        // twap last-second btc eth
        expectedStack[6] = 18.355922996327998332e18;
        // twap 30 mins btc eth
        expectedStack[5] = 18.350417320600948012e18;
        // twap current-price eth btc
        expectedStack[4] = 0.054474353339969539e18;
        // twap last-second eth btc
        expectedStack[3] = 0.054478328341214141e18;
        // twap 30 mins eth btc
        expectedStack[2] = 0.054494673474120834e18;
        // twap dai weth
        expectedStack[1] = 0.00044199420105985e18;
        // twap weth dai
        expectedStack[0] = 2262.473122050283788354e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "dai: 0x6B175474E89094C44Da98b954EedeAC495271d0F,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "current-price-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth 0 0 [uniswap-v3-fee-low]),",
                    "last-second-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth 2 1 [uniswap-v3-fee-low]),",
                    "last-30-mins-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth mul(60 30) 0 [uniswap-v3-fee-low]),",
                    "current-price-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc 0 0 [uniswap-v3-fee-low]),",
                    "last-second-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc 2 1 [uniswap-v3-fee-low]),",
                    "last-30-mins-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc mul(60 30) 0 [uniswap-v3-fee-low]),",
                    "weth-dai: uniswap-v3-twap-output-ratio(dai weth 1000 0 [uniswap-v3-fee-low]),"
                    "dai-weth: uniswap-v3-twap-output-ratio(weth dai 1000 0 [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-twap-output-ratio"
        );
    }

    function testUniswapWordsUniswapV3TwapZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ", address(uniswapWords).toHexString(), " ", "_: uniswap-v3-twap-output-ratio();"
                )
            ),
            0,
            5,
            0
        );
    }

    function testUniswapWordsUniswapV3TwapOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ", address(uniswapWords).toHexString(), " ", "_: uniswap-v3-twap-output-ratio(0);"
                )
            ),
            1,
            5,
            1
        );
    }

    function testUniswapWordsUniswapV3TwapTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v3-twap-output-ratio(0 0);"
                )
            ),
            2,
            5,
            2
        );
    }

    function testUniswapWordsUniswapV3TwapThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v3-twap-output-ratio(0 0 0);"
                )
            ),
            3,
            5,
            3
        );
    }

    function testUniswapWordsUniswapV3TwapFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v3-twap-output-ratio(0 0 0 0);"
                )
            ),
            4,
            5,
            4
        );
    }

    function testUniswapWordsUniswapV3TwapSixInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v3-twap-output-ratio(0 0 0 0 0 0);"
                )
            ),
            6,
            5,
            6
        );
    }

    function testUniswapWordsUniswapV3TwapZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    ": uniswap-v3-twap-output-ratio(0 0 0 0 0);"
                )
            ),
            5,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV3TwapTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v3-twap-output-ratio(0 0 0 0 0);"
                )
            ),
            5,
            1,
            2
        );
    }
}
