// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {LibDeploy} from "../src/lib/v3/LibDeploy.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_KEY"));
        LibDeploy.newUniswapWords(vm);
        vm.stopBroadcast();
    }
}
