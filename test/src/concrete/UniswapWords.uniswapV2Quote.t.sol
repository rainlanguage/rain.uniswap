// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibTestFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV2QuoteTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
    }

    function testUniswapWordsUniswapV2QuoteHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](5);
        // input
        // wbtc
        expectedStack[4] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[3] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // weth equivalent to 1e18 wbtc without slippage etc.
        expectedStack[2] = 18.347117686519845296e18;
        // timestamp
        expectedStack[1] = 1719126179e18;
        // weth-btc
        expectedStack[0] = 0.054504474058872404e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-current-output-ratio<1>(wbtc weth [uniswap-v2-factory] [uniswap-v2-init-code]),"
                    "weth-wbtc: uniswap-v2-current-output-ratio(weth wbtc [uniswap-v2-factory] [uniswap-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-current-output-ratio wbtc weth"
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio<1>();"
                )
            ),
            0,
            4,
            0
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio<1>(0);"
                )
            ),
            1,
            4,
            1
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio<1>(0 0);"
                )
            ),
            2,
            4,
            2
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio<1>(0 0 0xdeadbeef);"
                )
            ),
            3,
            4,
            3
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampFiveInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio<1>(0 0 0 0 0);"
                )
            ),
            5,
            4,
            5
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    ": uniswap-v2-current-output-ratio<1>(0 0 0 0);"
                )
            ),
            4,
            2,
            0
        );
    }

    function testUniswapWordsUniswapV2QuoteWithTimestampOneOutput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio<1>(0 0 0 0);"
                )
            ),
            4,
            2,
            1
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio();"
                )
            ),
            0,
            4,
            0
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio(0);"
                )
            ),
            1,
            4,
            1
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio(0 0);"
                )
            ),
            2,
            4,
            2
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio(0 0 0xdeadbeef);"
                )
            ),
            3,
            4,
            3
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampFiveInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-current-output-ratio(0 0 0 0 0);"
                )
            ),
            5,
            4,
            5
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    ": uniswap-v2-current-output-ratio(0 0 0 0);"
                )
            ),
            4,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV2QuoteWithoutTimestampTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-current-output-ratio(0 0 0 0);"
                )
            ),
            4,
            1,
            2
        );
    }
}
