// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {UniswapWords, UniswapExternConfig} from "../../concrete/UniswapWords.sol";

address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

library LibDeploy {
    function newQuoter(Vm vm) internal returns (address) {
        // https://book.getfoundry.sh/cheatcodes/get-code#examples
        string memory getCodePath = "out/quoter/Quoter.sol:Quoter";
        bytes memory code =
            abi.encodePacked(vm.getCode(getCodePath), abi.encode(vm.envOr("UNI_V3_FACTORY", UNISWAP_V3_FACTORY)));
        address quoter;
        assembly ("memory-safe") {
            quoter := create(0, add(code, 0x20), mload(code))
        }
        return quoter;
    }

    function newUniswapWords(Vm vm) internal returns (UniswapWords) {
        return new UniswapWords(
            UniswapExternConfig(
                vm.envOr("UNI_V2_FACTORY", UNISWAP_V2_FACTORY), vm.envOr("UNI_V3_QUOTER", newQuoter(vm))
            )
        );
    }
}
