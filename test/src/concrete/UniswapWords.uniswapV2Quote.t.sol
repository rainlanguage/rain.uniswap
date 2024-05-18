// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/lib/constants/ExpressionDeployerNPConstants.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract UniswapWordsUniswapV2QuoteTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
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
        // is 18 decimals for the 1e18 weth and an extra 10 for the difference
        // between wbtc and weth (8 vs 10).
        expectedStack[2] = 18379123452783257160;
        // timestamp
        expectedStack[1] = 1706347127;
        // weth-btc
        expectedStack[0] = 54409558898118408;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>(wbtc 8 weth 18),"
                    "weth-wbtc: uniswap-v2-spot-output-ratio(weth 18 wbtc 8);"
                )
            ),
            expectedStack,
            "uniswap-v2-spot-output-ratio wbtc weth"
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>();"
                )
            ),
            2,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>(wbtc);"
                )
            ),
            3,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>(wbtc weth);"
                )
            ),
            4,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>(wbtc weth 0xdeadbeef);"
                )
            ),
            5,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth timestamp: uniswap-v2-spot-output-ratio<1>(wbtc weth 0xdeadbeef 0xdeadc0de 1e18);"
                )
            ),
            7,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v2-spot-output-ratio<1>(wbtc weth 0xdeadbeef 0xdeadc0de);"
                )
            ),
            6,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v2-spot-output-ratio<1>(wbtc weth 0xdeadbeef 0xdeadc0de);"
                )
            ),
            6,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth: uniswap-v2-spot-output-ratio();"
                )
            ),
            2,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth: uniswap-v2-spot-output-ratio(wbtc);"
                )
            ),
            3,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth: uniswap-v2-spot-output-ratio(wbtc weth);"
                )
            ),
            4,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth: uniswap-v2-spot-output-ratio(wbtc weth 0xdeadbeef);"
                )
            ),
            5,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc-weth: uniswap-v2-spot-output-ratio(wbtc weth 0xdeadbeef 0xdeadc0de 1e18);"
                )
            ),
            7,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v2-spot-output-ratio(wbtc weth 0xdeadbeef 0xdeadc0de);"
                )
            ),
            6,
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
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_ _: uniswap-v2-spot-output-ratio(wbtc weth 0xdeadbeef 0xdeadc0de);"
                )
            ),
            6,
            1,
            2
        );
    }
}
