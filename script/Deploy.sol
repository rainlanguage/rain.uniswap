// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {LibDeploy} from "../src/lib/deploy/LibDeploy.sol";
import {IMetaBoardV1} from "rain.metadata/interface/IMetaBoardV1.sol";
import {LibDescribedByMeta} from "rain.metadata/lib/LibDescribedByMeta.sol";
import {UniswapWords} from "../src/concrete/UniswapWords.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        bytes memory subParserDescribedByMeta = vm.readFileBinary("meta/UniswapWords.rain.meta");
        IMetaBoardV1 metaboard = IMetaBoardV1(vm.envAddress("DEPLOY_METABOARD_ADDRESS"));

        vm.startBroadcast(deployerPrivateKey);

        UniswapWords subParser = LibDeploy.newUniswapWords(vm);

        LibDescribedByMeta.emitForDescribedAddress(metaboard, subParser, subParserDescribedByMeta);

        vm.stopBroadcast();
    }
}
