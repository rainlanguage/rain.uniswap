// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Script} from "forge-std/Script.sol";
import {UniswapWords, UniswapExternConfig} from "../src/concrete/UniswapWords.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_KEY"));
        new UniswapWords(UniswapExternConfig(vm.envAddress("UNI_V3_QUOTER")));
        vm.stopBroadcast();
    }
}
