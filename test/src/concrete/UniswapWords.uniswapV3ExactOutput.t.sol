// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV3ExactOutputTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(LibFork.rpcUrl(vm), BLOCK_NUMBER);
    }

    function testUniswapWordsUniswapV3ExactOutputHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // amount in 1 weth out ~0.054 btc in (btc)
        expectedStack[1] = 0.05450206e18;
        // amount in 1 wbtc out ~18.3 weth in (eth)
        expectedStack[0] = 18.369201836320617322e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "min-amount-in-wbtc-weth: uniswap-v3-quote-exact-output(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]),"
                    "min-amount-in-weth-wbtc: uniswap-v3-quote-exact-output(weth wbtc 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-quote-exact-output wbtc weth"
        );
    }

    function testUniswapWordsUniswapV3ExactOutputZeroInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_ _: uniswap-v3-quote-exact-output();"
                )
            ),
            2,
            6,
            0
        );
    }

    function testUniswapWordsUniswapV3ExactOutputOneInput() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc);"
                )
            ),
            3,
            6,
            1
        );
    }

    function testUniswapWordsUniswapV3ExactOutputTwoInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc weth);"
                )
            ),
            4,
            6,
            2
        );
    }

    function testUniswapWordsUniswapV3ExactOutputThreeInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc weth 1);"
                )
            ),
            5,
            6,
            3
        );
    }

    function testUniswapWordsUniswapV3ExactOutputFourInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc weth 1 0xdeadbeef);"
                )
            ),
            6,
            6,
            4
        );
    }

    function testUniswapWordsUniswapV3ExactOutputFiveInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc weth 1 0xdeadbeef 1);"
                )
            ),
            7,
            6,
            5
        );
    }

    function testUniswapWordsUniswapV3ExactOutputSevenInputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadInputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_: uniswap-v3-quote-exact-output(wbtc weth 1 0xdeadbeef 1 1 0);"
                )
            ),
            9,
            6,
            7
        );
    }

    function testUniswapWordsUniswapV3ExactOutputZeroOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    ": uniswap-v3-quote-exact-output(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            8,
            1,
            0
        );
    }

    function testUniswapWordsUniswapV3ExactOutputTwoOutputs() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        checkBadOutputs(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "_ _: uniswap-v3-quote-exact-output(wbtc weth 1 [uniswap-v3-factory] [uniswap-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            8,
            1,
            2
        );
    }
}
