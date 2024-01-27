// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Script} from "forge-std/Script.sol";
import {UniswapWords, UniswapExternConfig} from "../src/concrete/UniswapWords.sol";

contract Deploy is Script {
    function newQuoter() internal returns (address) {
        // https://book.getfoundry.sh/cheatcodes/get-code#examples
        bytes memory code = abi.encodePacked(
            vm.getCode("quoter/Quoter.sol:Quoter"), abi.encode(vm.envAddress("UNI_V3_FACTORY"))
        );
        address quoter;
        assembly ("memory-safe") {
            quoter := create(0, add(code, 0x20), mload(code))
        }
        return quoter;
    }

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_KEY"));
        new UniswapWords(UniswapExternConfig(vm.envOr("UNI_V3_QUOTER", newQuoter())));
        vm.stopBroadcast();
    }
}
