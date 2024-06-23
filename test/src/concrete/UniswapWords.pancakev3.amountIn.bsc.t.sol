// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_BSC} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsPancakeV3AmountInEthereumTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkBsc(vm);
    }

    function testUniswapWordsPancakeV3AmountInHappyFork() external {
        vm.chainId(CHAIN_ID_BSC);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbnb
        expectedStack[3] = uint256(uint160(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0x55d398326f99059fF775485246999027B3197955));
        // amount in 1 weth out
        expectedStack[1] = 0.001693046836968249e18;
        // amount in 1 wbtc out
        expectedStack[0] = 590.775182115905551393e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbnb: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,",
                    "bsc-usd: 0x55d398326f99059fF775485246999027B3197955,",
                    "min-amount-in-wbtc-weth: uniswap-v3-quote-exact-output(wbnb bsc-usd 1 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-lowest]),",
                    "min-amount-in-weth-wbtc: uniswap-v3-quote-exact-output(bsc-usd wbnb 1 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-lowest]);"
                )
            ),
            expectedStack,
            "uniswap-v3-quote-exact-output wbtc weth pancake-v3"
        );
    }
}
