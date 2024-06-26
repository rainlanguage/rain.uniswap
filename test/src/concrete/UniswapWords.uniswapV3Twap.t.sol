// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibTestFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV3TwapTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
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
        expectedStack[7] = 18.344221561909405853e18;
        // twap last-second btc eth
        expectedStack[6] = 18.343078988347495563e18;
        // twap 30 mins btc eth
        expectedStack[5] = 18.343078988347495563e18;
        // twap current-price eth btc
        expectedStack[4] = 0.05451307904372653e18;
        // twap last-second eth btc
        expectedStack[3] = 0.054516474613408875e18;
        // twap 30 mins eth btc
        expectedStack[2] = 0.054516474613408875e18;
        // twap dai weth
        expectedStack[1] = 0.000285008413462788e18;
        // twap weth dai
        expectedStack[0] = 3508.668350699629254295e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "dai: 0x6B175474E89094C44Da98b954EedeAC495271d0F,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "current-price-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth 0 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "last-second-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth 2 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "last-30-mins-btc-eth: uniswap-v3-twap-output-ratio(wbtc weth mul(60 30) 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "current-price-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc 0 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "last-second-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc 2 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "last-30-mins-eth-btc: uniswap-v3-twap-output-ratio(weth wbtc mul(60 30) 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "weth-dai: uniswap-v3-twap-output-ratio(dai weth 1000 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),"
                    "dai-weth: uniswap-v3-twap-output-ratio(weth dai 1000 0 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
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
            7,
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
            7,
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
            7,
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
            7,
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
            7,
            4
        );
    }

    function testUniswapWordsUniswapV3TwapFiveInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v3-twap-output-ratio(0 0 0 0 0);"
                )
            ),
            5,
            7,
            5
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
            7,
            6
        );
    }

    function testUniswapWordsUniswapV3TwapEightInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v3-twap-output-ratio(0 0 0 0 0 0 0 0);"
                )
            ),
            8,
            7,
            8
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
                    ": uniswap-v3-twap-output-ratio(0 0 0 0 0 0 0);"
                )
            ),
            7,
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
                    "_ _: uniswap-v3-twap-output-ratio(0 0 0 0 0 0 0);"
                )
            ),
            7,
            1,
            2
        );
    }
}
