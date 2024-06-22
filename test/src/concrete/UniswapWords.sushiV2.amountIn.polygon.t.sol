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
        LibTestFork.forkPolygon(vm);
    }

    function testUniswapWordsUniswapV2AmountInHappyFork() external {
        vm.chainId(CHAIN_ID_POLYGON);

        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // input
        // wbtc
        expectedStack[3] = uint256(uint160(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6));
        // output
        // weth
        expectedStack[2] = uint256(uint160(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619));
        // min amount in
        expectedStack[1] = 0.05518008e18;
        // timestamp
        expectedStack[0] = 1719087041e18;

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wbtc: 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6,",
                    "weth: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619,",
                    "min-amount-in timestamp: uniswap-v2-quote-exact-output<1>(wbtc weth 1 [sushi-v2-factory] [sushi-v2-init-code]);"
                )
            ),
            expectedStack,
            "uniswap-v2-quote-exact-output wbtc weth sushi-v2"
        );
    }
}
