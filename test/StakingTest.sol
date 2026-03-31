//SPDX-License-1dentifier: LGPL-3.0-onlY
//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";

contract StakingTest is Test {
    StakingToken stakingToken;
    string name_ = "Staking Token";
    string symbol_ = "STK";
    address admin = vm.addr(1);

    // viene el staking
    StakingApp stakingApp;
    uint256 stakingPeriod_ = 2;
    uint256 fixedStakingAmount_ = 3;
    uint256 rewardPeriod_ = 1;

    function setUp() public {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(
            address(stakingToken),
            admin,
            stakingPeriod_,
            fixedStakingAmount_,
            rewardPeriod_
        );
    }

    function testChangeStakingPeriodCorretly() public {
        vm.startPrank(admin);

        uint256 newStakingPeriod_ = 1;

        stakingApp.changeStakingPeriod(newStakingPeriod_);

        vm.stopPrank();
    }
}
