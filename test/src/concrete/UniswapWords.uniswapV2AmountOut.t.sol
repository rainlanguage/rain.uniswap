// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibTestFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV2AmountOutTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
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
        expectedStack[1] = 18.121332968504208195e18;
        // timestamp
        expectedStack[0] = 1719126179e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(wbtc weth 1 [uniswap-v2-factory] [uniswap-v2-init-code]);"
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
        expectedStack[1] = 0.05431306e18;
        // timestamp
        expectedStack[0] = 1719126179e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "max-amount-out timestamp: uniswap-v2-quote-exact-input<1>(weth wbtc 1 [uniswap-v2-factory] [uniswap-v2-init-code]);"
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
                    "_ _: uniswap-v2-quote-exact-input<1>();"
                )
            ),
            0,
            5,
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
                    "_ _: uniswap-v2-quote-exact-input<1>(0xdeadbeef);"
                )
            ),
            1,
            5,
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
                    "_ _: uniswap-v2-quote-exact-input<1>(0xdeadbeef 0xdeadc0de);"
                )
            ),
            2,
            5,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-input<1>(0xdeadbeef 0xdeadc0de 0xdeadbeef);"
                )
            ),
            3,
            5,
            3
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithTimestampFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-input<1>(0xdeadbeef 0xdeadc0de 0xdeadbeef 0xdeadc0de);"
                )
            ),
            4,
            5,
            4
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
                    ": uniswap-v2-quote-exact-input<1>(0 0 1 0 0);"
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
                    "_: uniswap-v2-quote-exact-input<1>(0 0 1 0 0);"
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
                    "using-words-from ", address(uniswapWords).toHexString(), " ", "_: uniswap-v2-quote-exact-input();"
                )
            ),
            0,
            5,
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
                    "_: uniswap-v2-quote-exact-input(0xdeadbeef);"
                )
            ),
            1,
            5,
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
                    "_: uniswap-v2-quote-exact-input(0xdeadbeef 0xdeadc0de);"
                )
            ),
            2,
            5,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-input(0xdeadbeef 0xdeadc0de 0xdeadbeef);"
                )
            ),
            3,
            5,
            3
        );
    }

    function testUniswapWordsUniswapV2AmountOutWithoutTimestampFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-input(0xdeadbeef 0xdeadc0de 0xdeadbeef 0xdeadc0de);"
                )
            ),
            4,
            5,
            4
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
                    ": uniswap-v2-quote-exact-input(0 0 1 0 0);"
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
                    "_ _: uniswap-v2-quote-exact-input(0 0 1 0 0);"
                )
            ),
            5,
            1,
            2
        );
    }
}
