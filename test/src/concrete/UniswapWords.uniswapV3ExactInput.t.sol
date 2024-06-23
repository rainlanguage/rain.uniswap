// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibTestFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV3ExactOutputTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
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
        // amount out 1 wbtc in ~18.3 weth out
        expectedStack[1] = 18.332954714187830414e18;
        // amount out 1 weth in ~0.054 wbtc out
        expectedStack[0] = 0.05448548e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    // 1e8 is 1 btc because of the decimals.
                    "max-amount-out-1e-10-btc-weth: uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),",
                    "max-amount-out-1-weth-btc: uniswap-v3-quote-exact-input(weth wbtc 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-quote-exact-input wbtc weth"
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input();"
                )
            ),
            2,
            6,
            0
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc);"
                )
            ),
            3,
            6,
            1
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc weth);"
                )
            ),
            4,
            6,
            2
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc weth 1);"
                )
            ),
            5,
            6,
            3
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-fee-low]);"
                )
            ),
            6,
            6,
            4
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampFiveInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-fee-low] 1);"
                )
            ),
            7,
            6,
            5
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampSevenInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low] 1);"
                )
            ),
            9,
            6,
            7
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            8,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV3ExactInputWithTimestampTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_ _: uniswap-v3-quote-exact-input(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            8,
            1,
            2
        );
    }
}
