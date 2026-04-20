// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";

contract StakingTest is Test {
    StakingToken stakingToken;
    string name_ = "Staking Token";
    string symbol_ = "STK";
    address admin = vm.addr(1);

    uint256 newStakingPeriodRandom = vm.randomUint(1, 100);
    uint256 rewardRate = 1e16;

    StakingApp stakingApp;
    uint256 stakingPeriod_ = 2;
    uint256 fixedStakingAmount_ = 1 ether;

    function setUp() public {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(
            address(stakingToken),
            admin,
            stakingPeriod_,
            fixedStakingAmount_,
            rewardRate
        );
    }

    /// @notice Prueba que solo el owner puede cambiar el periodo de staking.
    function testChangeStakingPeriodCorretly() public {
        vm.startPrank(admin);

        uint256 newStakingPeriod_ = newStakingPeriodRandom;

        stakingApp.changeStakingPeriod(newStakingPeriod_);

        assert(stakingApp.getStakingPeriod() == newStakingPeriod_);

        vm.stopPrank();
    }

    /// @notice Prueba que una cuenta no autorizada no puede cambiar el periodo.
    function testChangeStakingPeriodFailed() public {
        vm.startPrank(vm.addr(2));

        uint256 newStakingPeriod_ = newStakingPeriodRandom;

        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod_);

        vm.stopPrank();
    }

    /// @notice Verifica que el contrato acepta transferencias ETH directas.
    function testRecivedEtherStakingTokenCorrectly() public {
        vm.startPrank(admin);
        vm.deal(admin, 1 ether);

        uint256 valueEther = 1 ether;
        uint256 balanceBefore = address(stakingApp).balance;

        (bool success, ) = address(stakingApp).call{value: valueEther}("");
        require(success, "transfer failed");

        uint256 balanceAfter = address(stakingApp).balance;
        assert(balanceAfter - balanceBefore == valueEther);

        vm.stopPrank();
    }

    /// @notice Prueba de depósito y retiro de tokens sin reclamar recompensas.
    function testDepositAndWithdraw() public {
        vm.startPrank(vm.addr(4));

        // 1. Mint de tokens para el usuario.
        stakingToken.mint(1 ether);

        uint256 balanceBefore_ = IERC20(address(stakingToken)).balanceOf(
            vm.addr(4)
        );

        // 2. El usuario aprueba el contrato para gastar su token.
        stakingToken.approve(address(stakingApp), 1 ether);

        // 3. Deposita el monto fijo de staking.
        stakingApp.depositTokens(1 ether);

        // 4. Simula el paso del tiempo.
        vm.warp(block.timestamp + 100);

        // 5. Retira los tokens stakeados.
        stakingApp.witdrawTokens();

        uint256 balanceAfter_ = IERC20(address(stakingToken)).balanceOf(
            vm.addr(4)
        );

        assert(balanceAfter_ == balanceBefore_);
        assertEq(stakingApp.getBalanceUser(), 0);

        vm.stopPrank();
    }

    /// @notice Prueba que dos usuarios comparten el reward proporcional al tiempo stakeado.
    function testDepositAndClaimRewardPerTwoWallet() public {
        // Asegura ETH en el contrato para pagar la recompensa.
        vm.deal(address(stakingApp), 1000 ether);

        // Usuario 1 deposita primero.
        vm.startPrank(vm.addr(3));
        stakingToken.mint(1 ether);
        stakingToken.approve(address(stakingApp), 1 ether);
        stakingApp.depositTokens(1 ether);
        vm.stopPrank();

        // Avanza 60 segundos y usuario 2 deposita.
        vm.warp(block.timestamp + 60);
        vm.startPrank(vm.addr(4));
        stakingToken.mint(1 ether);
        stakingToken.approve(address(stakingApp), 1 ether);
        stakingApp.depositTokens(1 ether);
        vm.stopPrank();

        // Avanza 100 segundos y el usuario 2 reclama su recompensa.
        vm.warp(block.timestamp + 100);
        vm.startPrank(vm.addr(4));

        uint256 reward_ = stakingApp.earned(vm.addr(4));
        assertEq(reward_, 5e17);

        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCheckBalancePerUser() public {
        vm.deal(address(stakingApp), 1000 ether);
        vm.startPrank(vm.addr(3));
        stakingToken.mint(fixedStakingAmount_);
        stakingToken.approve(address(stakingApp), fixedStakingAmount_);
        stakingApp.depositTokens(fixedStakingAmount_);
        vm.warp(block.timestamp + 100);

        stakingApp.witdrawTokens();

        vm.warp(block.timestamp + 100);

        vm.expectRevert();
        stakingApp.witdrawTokens();

        vm.expectRevert();
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCheckFixedStakingAmount() public {
        vm.deal(address(stakingApp), 1000 ether);
        vm.startPrank(vm.addr(3));
        stakingToken.mint(2 ether);
        stakingToken.approve(address(stakingApp), 2 ether);
        vm.expectRevert();
        stakingApp.depositTokens(2 ether);
    }

    function testCheckElapsePeriod() public {
        vm.deal(address(stakingApp), 1000 ether);
        vm.startPrank(vm.addr(3));
        stakingToken.mint(fixedStakingAmount_);
        stakingToken.approve(address(stakingApp), fixedStakingAmount_);
        stakingApp.depositTokens(fixedStakingAmount_);

        vm.expectRevert();
        stakingApp.claimRewards();

        vm.stopPrank();
    }
}
