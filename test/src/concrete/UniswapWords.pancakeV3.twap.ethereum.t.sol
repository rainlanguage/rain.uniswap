// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_ETHEREUM} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsPancakeV3TwapBscTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkEthereum(vm);
    }

    function testUniswapWordsPancakeV3TwapHappyForkEthereum() external {
        vm.chainId(CHAIN_ID_ETHEREUM);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](3);
        // usdt
        expectedStack[2] = uint256(uint160(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        // wbnb
        expectedStack[1] = uint256(uint160(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        // twap wbnb usdt
        expectedStack[0] = 0.99944969431675814e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "usdt: 0xdAC17F958D2ee523a2206206994597C13D831ec7,",
                    "usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,",
                    "current-price-wbnb-usdt: uniswap-v3-twap-output-ratio(usdt usdc 0 0 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-lowest]);"
                )
            ),
            expectedStack,
            "uniswap-v3-twap-output-ratio pancakeV3 twap ethereum"
        );
    }
}
