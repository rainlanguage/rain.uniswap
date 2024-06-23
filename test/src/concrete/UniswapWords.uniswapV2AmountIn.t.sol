// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibTestFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV2AmountInTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
    }

    function testUniswapWordsUniswapV2AmountInHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // min amount in
        expectedStack[1] = 0.05469666e18;
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
                    "min-amount-in timestamp: uniswap-v2-quote-exact-output<1>(wbtc weth 1 [uniswap-v2-factory] [uniswap-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-output wbtc weth"
        );
    }

    // Test a fork in the reverse direction, from weth to wbtc.
    function testUniswapWordsUniswapV2AmountInHappyForkReverse() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // weth
        expectedStack[3] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // output
        // wbtc
        expectedStack[2] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // min amount in
        expectedStack[1] = 18.577896588625293797e18;
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
                    "min-amount-in timestamp: uniswap-v2-quote-exact-output<1>(weth wbtc 1 [uniswap-v2-factory] [uniswap-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-output weth wbtc"
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>();"
                )
            ),
            0,
            5,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>(0);"
                )
            ),
            1,
            5,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>(0 0);"
                )
            ),
            2,
            5,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>(0 0 0);"
                )
            ),
            3,
            5,
            3
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>(0 0 1 0);"
                )
            ),
            4,
            5,
            4
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampSixInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output<1>(0 0 1 0 0 0);"
                )
            ),
            6,
            5,
            6
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    ": uniswap-v2-quote-exact-output<1>(0 0 1 0 0);"
                )
            ),
            5,
            2,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampOneOutput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output<1>(0 0 1 0 0);"
                )
            ),
            5,
            2,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountInWithTimestampThreeOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _ _: uniswap-v2-quote-exact-output<1>(0 0 1 0 0);"
                )
            ),
            5,
            2,
            3
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ", address(uniswapWords).toHexString(), " ", "_: uniswap-v2-quote-exact-output();"
                )
            ),
            0,
            5,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output(0);"
                )
            ),
            1,
            5,
            1
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output(0 0);"
                )
            ),
            2,
            5,
            2
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output(0 0 0);"
                )
            ),
            3,
            5,
            3
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output(0 0 1 0);"
                )
            ),
            4,
            5,
            4
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampSixInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_: uniswap-v2-quote-exact-output(0 0 1 0 0 0);"
                )
            ),
            6,
            5,
            6
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    ": uniswap-v2-quote-exact-output(0 0 1 0 0);"
                )
            ),
            5,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV2AmountInWithoutTimestampTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "_ _: uniswap-v2-quote-exact-output(0 0 1 0 0);"
                )
            ),
            5,
            1,
            2
        );
    }
}
