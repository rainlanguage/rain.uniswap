// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibTestFork} from "../../lib/LibTestFork.sol";
import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {CHAIN_ID_BSC} from "src/lib/chain/LibChainId.sol";

contract UniswapWordsPancakeV2AmountInBscTest is OpTest {
    using Strings for address;

    function beforeOpTestConstructor() internal override {
        LibTestFork.forkBsc(vm);
    }

    function testUniswapWordsPancakeV2AmountInHappyFork() external {
        vm.chainId(CHAIN_ID_BSC);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // btcb
        expectedStack[3] = uint256(uint160(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0x2170Ed0880ac9A755fd29B2688956BD959F933F8));
        // min amount in
        expectedStack[1] = 0.054725816845315393e18;
        // timestamp
        expectedStack[0] = 1719095887e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "btcb: 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c,",
                    "ethb: 0x2170Ed0880ac9A755fd29B2688956BD959F933F8,",
                    "min-amount-in timestamp: uniswap-v2-quote-exact-output<1>(btcb ethb 1 [pancake-v2-factory] [pancake-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-output wbtc weth pancake-v2"
        );
    }
}
