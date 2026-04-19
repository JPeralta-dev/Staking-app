// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    string name_ = "Staking Token";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name_, symbol_);
    }

    /// @notice Verifica que la función mint aumenta el balance del usuario.
    function testStakingTokenMintsCorrectly() public {
        vm.startPrank(randomUser);

        uint256 amount_ = 1 ether;
        uint256 balanceBefore_ = IERC20(address(stakingToken)).balanceOf(
            randomUser
        );

        stakingToken.mint(amount_);

        uint256 balanceAfter_ = IERC20(address(stakingToken)).balanceOf(
            randomUser
        );

        assert(balanceAfter_ - balanceBefore_ == amount_);

        vm.stopPrank();
    }
}
