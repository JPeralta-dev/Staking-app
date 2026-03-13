//SPDX-License-1dentifier: LGPL-3.0-onlY
//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// libreriras de openzepelin muy auditadas

error NotIsValueAcceptError();
error UserNotAlredyError();
contract StakingApp is Ownable {
    //variables

    // 1. StakingToken address cuando inicialicemos necesitamos saber que token recibimos
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    mapping(address => uint256) balances;
    // 2. Admin con Ownabl

    // modificadores

    // eventos
    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    constructor(
        address stakingToken_,
        address owner_,
        uint256 stakingPeriod_,
        uint256 fixedStakingAmount_
    ) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
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
        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }
    // WITHDRAW

    // CLAIM REWARDS

    // funciones externas

    // funciones internas
}
