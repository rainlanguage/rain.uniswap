// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_ETHEREUM, CHAIN_ID_POLYGON} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsSushiV2AmountInEthereumTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
    }

    function testUniswapWordsUniswapV2AmountInHappyFork() external {
        vm.chainId(CHAIN_ID_ETHEREUM);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // min amount in
        expectedStack[1] = 0.0546837e18;
        // timestamp
        expectedStack[0] = 1719129623e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,",
                    "weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,",
                    "min-amount-in timestamp: uniswap-v2-quote-exact-output<1>(wbtc weth 1 [sushi-v2-factory] [sushi-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-output wbtc weth sushi-v2"
        );
    }
}
