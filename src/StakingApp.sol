//SPDX-License-1dentifier: LGPL-3.0-onlY
//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// libreriras de openzepelin muy auditadas

error NotIsValueAcceptError();
error UserNotAlredyError();
error InsufficientBalance();
error NeedToWaitRewardError();
error TransferFailed();

contract StakingApp is Ownable {
    //variables

    // 1. StakingToken address cuando inicialicemos necesitamos saber que token recibimos
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;
    mapping(address => uint256) balances;
    mapping(address => uint256) publicTime; // tiempo para que pueda vovler a hacer reclamacon de tokens

    // 2. Admin con Ownabl

    // modificadores
    modifier checkClaimRewards() {
        if (balances[msg.sender] < fixedStakingAmount)
            revert InsufficientBalance();
        _;
    }

    modifier checkBalance() {
        if (balances[msg.sender] <= 0) revert InsufficientBalance();
        _;
    }

    // eventos
    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WitdrawTokens(address userAddress_);
    event EtherReceived(uint256 amount_);
    constructor(
        address stakingToken_,
        address owner_,
        uint256 stakingPeriod_,
        uint256 fixedStakingAmount_,
        uint256 rewardPeriod_
    ) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPeriod_;
    }

    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    // DEPOSIT TOKEN

    function depositTokens(uint256 tokenAmountToDeposit_) external {
        if (tokenAmountToDeposit_ != fixedStakingAmount)
            revert NotIsValueAcceptError();
        if (balances[msg.sender] != 0) revert UserNotAlredyError();
        // TranferFrom (Adonde voy a quitar los toknes, a quien se lo envio?, cuanto es la vaina)
        IERC20(stakingToken).transferFrom(
            msg.sender,
            address(this),
            tokenAmountToDeposit_
        );
        balances[msg.sender] += tokenAmountToDeposit_;
        publicTime[msg.sender] = block.timestamp;
        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }
    // WITHDRAW
    function witdrawTokens() external checkBalance {
        uint256 userBalance_ = balances[msg.sender];
        balances[msg.sender] -= userBalance_;
        emit WitdrawTokens(msg.sender);
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
    }
    // CLAIM REWARDS
    function claimRewards() external checkClaimRewards {
        // 1. check balance

        // 2. calculate reward amount
        uint256 elapsePeriod_ = block.timestamp - publicTime[msg.sender];
        if (elapsePeriod_ < stakingPeriod) revert NeedToWaitRewardError();
        // 3. update state
        publicTime[msg.sender] = block.timestamp;

        // 4. Tranfer Reward
        (bool success, ) = msg.sender.call{value: rewardPerPeriod}("");
        if (success == false) revert TransferFailed();
    }

    receive() external payable {
        emit EtherReceived(msg.value);
    }
}
