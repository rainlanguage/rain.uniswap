// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "rain.interpreter/../test/util/abstract/OpTest.sol";
import {UniswapWords, UniswapExternConfig} from "src/concrete/UniswapWords.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from
    "rain.interpreter/../test/util/lib/constants/ExpressionDeployerNPConstants.sol";
import {LibDeploy} from "src/lib/v3/LibDeploy.sol";

contract TwapForkTest is OpTest {

    using Strings for address;

    uint256 constant BLOCK_NUMBER = 52430220;

    function beforeOpTestConstructor() internal override {
        vm.createSelectFork("https://1rpc.io/matic", BLOCK_NUMBER);
    }

    function constructionMetaPath() internal pure override returns (string memory) {
        return string.concat("lib/rain.interpreter/", EXPRESSION_DEPLOYER_NP_META_PATH);
    } 

    function testUniswapWordsUniswapV3TwapHappyForkPolygon() external {
        UniswapWords uniswapWords = LibDeploy.newUniswapWords(vm);

        uint256[] memory expectedStack = new uint256[](4);
        // trade
        expectedStack[3] = uint256(uint160(0x692AC1e363ae34b6B489148152b12e2785a3d8d6));
        // usdt
        expectedStack[2] = uint256(uint160(0xc2132D05D31c914a87C6611C10748AEb04B58e8F));
        // assertion not a concern for now
        expectedStack[1] = 11;
        expectedStack[0] = 11; 

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(uniswapWords).toHexString(),
                    " ",
                    "trade: 0x692AC1e363ae34b6B489148152b12e2785a3d8d6,",
                    "usdt: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F,",
                    "trend-numerator: uniswap-v3-twap-output-ratio(usdt 6 trade 18 1800 0 [uniswap-v3-fee-high]),"
                    "trend-denominator: uniswap-v3-twap-output-ratio(usdt 6 trade 18 14400 0 [uniswap-v3-fee-high]);"

                )
            ),
            expectedStack,
            "uniswap-v3-twap-output-ratio"
        );
    }


}