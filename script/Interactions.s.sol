// pragma solidity ^0.8.18;

// import {HelperConfig} from "./HelperConfig.s.sol";
// // import {vrfCoodinatorV2Mock} form "@chinlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

// import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

// import {Script, console} from "forge-std/Script.sol";
// import {LinkToken} from "../test/mocks/LinkToken.sol";
// import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

// contract CreateSubscription is Script {
//     function createSubscriptionUsingConfig() public returns (uint64) {
//         HelperConfig helperConfig = new HelperConfig();

//         (
//             ,
//             ,
//             address vrfCoordinator,
//             ,
//             uint subId,
//             ,
//             address link
//         ) = helperConfig.activeNetworkConfig();

//         return createSubscription(vrfCoordinator);
//     }

//     function createSubscription(
//         address vrfCoordinator
//     ) public returns (uint64) {
//         console.log("Creating subscription on chainId: ", block.chainid);

//         vm.startBroadcast();

//         uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
//             .createSubscription();

//         vm.stopBroadcast();

//         console.log("Your sub Id is: ", subId);
//         console.log("Please update subscriptionId in HelperConfig.s.sol");
//         return subId;
//     }

//     function run() external returns (uint64) {
//         return createSubscriptionUsingConfig();
//     }
// }

// // contract

// contract FundSubscription is Script {
//     uint96 public constant FUND_AMOUNT = 3 ether;

//     function FundSubscriptionUsingConfig() public {
//         HelperConfig helperConfig = new HelperConfig();
//         (
//             ,
//             ,
//             address vrfCoordinator,
//             ,
//             uint64 subId,
//             ,
//             address link
//         ) = helperConfig.activeNetworkConfig();
//         fundSubscription(vrfCoordinator, subId, link);
//     }

//     function fundSubscription(
//         address vrfCoordinator,
//         uint64 subId,
//         address link
//     ) public {
//         console.log("Funding subscription: ", subId);
//         console.log("Using vrfCoordinator: ", vrfCoordinator);
//         console.log("On chainID: ", block.chainid);
//         if (block.chainid == 31337) {
//             vm.startBroadcast();

//             VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
//                 subId,
//                 FUND_AMOUNT
//             );

//             vm.stopBroadcast();
//         } else {
//             vm.startBroadcast();

//             LinkToken(link).transferAndCall(
//                 vrfCoordinator,
//                 FUND_AMOUNT,
//                 abi.encode(subId)
//             );
//             vm.stopBroadcast();
//         }
//     }

//     function run() external {
//         FundSubscriptionUsingConfig();
//     }
//     // function createSubscription(address vrfCoordinator) public returns(uint)
// }

// contract AddConsumer is Script {
//     function addConsumer(
//         address raffle,
//         address vrfCoordinator,
//         uint64 subId
//     ) public {
//         console.log("Adding consumer contract: ", raffle);
//         console.log("Using vrfCoordinator: ", vrfCoordinator);
//         console.log("On ChainID: ", block.chainid);
//         vm.broadcast();

//         VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, raffle);
//         vm.stopBroadcast();
//     }

//     function addConsumerUsingConfig(address raffle) public {
//         HelperConfig helperConfig = new HelperConfig();
//         (, , address vrfCoordinator, , uint64 subId, , ) = helperConfig
//             .activeNetworkConfig();
//         addConsumer(raffle, vrfCoordinator, subId);
//     }

//     function run() external {
//         address raffle = DevOpsTools.get_most_recent_deployment(
//             "Raffle",
//             block.chainid
//         );
//         addConsumerUsingConfig(raffle);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            ,
            ,
            ,
            address vrfCoordinatorV2,
            ,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2, deployerKey);
    }

    function createSubscription(
        address vrfCoordinatorV2,
        uint256 deployerKey
    ) public returns (uint64) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast(deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinatorV2)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint64 subId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subId,
            ,
            ,
            ,
            ,
            address vrfCoordinatorV2,
            ,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(mostRecentlyDeployed, vrfCoordinatorV2, subId, deployerKey);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subId,
            ,
            ,
            ,
            ,
            address vrfCoordinatorV2,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinatorV2, subId, link, deployerKey);
    }

    function fundSubscription(
        address vrfCoordinatorV2,
        uint64 subId,
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinatorV2).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCoordinatorV2,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
