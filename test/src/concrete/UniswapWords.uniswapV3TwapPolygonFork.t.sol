// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "rain.interpreter/../test/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {BLOCK_NUMBER, LibFork} from "../../lib/LibTestFork.sol";
import {LibDeploy} from "src/lib/deploy/LibDeploy.sol";

contract UniswapWordsUniswapV3PolygonTwapTest is OpTest {
    using Strings for address;

    uint256 constant POLYGON_BLOCK_NUMBER = 58476746;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork(vm.envString("RPC_URL_POLYGON_FORK"), POLYGON_BLOCK_NUMBER);
    }

    function testPolygonUniswapWordsUniswapV3TwapHappyFork() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // wmatic
        expectedStack[3] = uint256(uint160(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270));
        // usdt
        expectedStack[2] = uint256(uint160(0xc2132D05D31c914a87C6611C10748AEb04B58e8F));
        // quickswap-factory
        expectedStack[1] = uint256(uint160(0x411b0fAcC3489691f28ad58c47006AF5E3Ab3A28));
        // twap current-price wmatic usdt
        expectedStack[0] = 574559951252499614;
       
        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "wmatic: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270,",
                    "usdt: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F,",
                    "quickswap-factory: 0x411b0fAcC3489691f28ad58c47006AF5E3Ab3A28,",
                    "current-price-wmatic-usdt: uniswap-v3-twap-output-ratio(wmatic usdt 0 0 quickswap-factory 0x4b9e4a8044ce5695e06fce9421a63b6f5c3db8a561eebb30ea4c775469e36eaf [uniswap-v3-fee-low]);"
                )
            ),
            expectedStack,
            "uniswap-v3-twap-output-ratio"
        ); 

    }
}