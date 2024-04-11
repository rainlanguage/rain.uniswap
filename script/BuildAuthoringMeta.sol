// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Script} from "forge-std/Script.sol";
import {LibUniswapSubParser} from "../src/abstract/UniswapSubParser.sol";

/// @title Subparser Authoring Meta
contract BuildAuthoringMeta is Script {
    function run() external {
        vm.writeFileBinary("meta/AuthoringMeta.rain.meta", LibUniswapSubParser.authoringMetaV2());
    }
}
