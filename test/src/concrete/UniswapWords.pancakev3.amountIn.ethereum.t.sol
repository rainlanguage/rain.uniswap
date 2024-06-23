// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_ETHEREUM} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsPancakeV3AmountInEthereumTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
    }

    function testUniswapWordsPancakeV3AmountInHappyFork() external {
        vm.chainId(CHAIN_ID_ETHEREUM);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        // amount in 1 weth out
        expectedStack[1] = 0.05457205e18;
        // amount in 1 wbtc out
        expectedStack[0] = 1706347955e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,",
                    "usdt: 0xdAC17F958D2ee523a2206206994597C13D831ec7,",
                    "min-amount-in-wbtc-weth: uniswap-v3-quote-exact-output(usdc usdt 1 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-lowest]),",
                    "min-amount-in-weth-wbtc: uniswap-v3-quote-exact-output(usdt usdc 1 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-lowest]);"
                )
            ),
            expectedStack,
            "uniswap-v3-quote-exact-output wbtc weth pancake-v3"
        );
    }
}