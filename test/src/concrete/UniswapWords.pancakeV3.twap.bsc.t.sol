// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_BSC} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsPancakeV3TwapBscTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkBsc(vm);
    }

    function testUniswapWordsPancakeV3TwapHappyFork() external {
        vm.chainId(CHAIN_ID_BSC);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](3);
        // usdt
        expectedStack[2] = uint256(uint160(0x55d398326f99059fF775485246999027B3197955));
        // wbnb
        expectedStack[1] = uint256(uint160(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
        // twap wbnb usdt
        expectedStack[0] = 590728855368450444399;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "usdt: 0x55d398326f99059fF775485246999027B3197955,",
                    "wbnb: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,",
                    "current-price-wbnb-usdt: uniswap-v3-twap-output-ratio(wbnb usdt 0 0 [pancake-v3-factory] [pancake-v3-init-code] [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-twap-output-ratio pancakeV3 twap bsc"
        );
    }
}
