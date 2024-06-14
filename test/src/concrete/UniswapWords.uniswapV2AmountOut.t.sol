// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract UniswapWordsUniswapV2AmountOutTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function testUniswapWordsUniswapV2AmountOutHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // max amount out
        expectedStack[1] = 18.153612651961048307e18;
        // timestamp
        expectedStack[0] = 1706347127e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(wbtc weth 1);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-input wbtc weth"
        );
    }

    // Test a fork in the reverse direction, from weth to wbtc.
    function testUniswapWordsUniswapV2AmountOutHappyForkReverse() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // weth
        expectedStack[3] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // output
        // wbtc
        expectedStack[2] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // max amount out
        expectedStack[1] = 0.05421864e18;
        // timestamp
        expectedStack[0] = 1706347127e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(weth wbtc 1);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-input weth wbtc"
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>();"
                )
            ),
            2,
            3,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(0xdeadbeef);"
                )
            ),
            3,
            3,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(0xdeadbeef 0xdeadc0de);"
                )
            ),
            4,
            3,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v2-quote-exact-input<1>(wbtc weth 1);"
                )
            ),
            5,
            2,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampOneOutput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v2-quote-exact-input<1>(wbtc weth 1);"
                )
            ),
            5,
            2,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out: uniswap-v2-quote-exact-input();"
                )
            ),
            2,
            3,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out: uniswap-v2-quote-exact-input(0xdeadbeef);"
                )
            ),
            3,
            3,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out: uniswap-v2-quote-exact-input(0xdeadbeef 0xdeadc0de);"
                )
            ),
            4,
            3,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v2-quote-exact-input(wbtc weth 1);"
                )
            ),
            5,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_ _: uniswap-v2-quote-exact-input(wbtc weth 1);"
                )
            ),
            5,
            1,
            2
        );
    }
}
