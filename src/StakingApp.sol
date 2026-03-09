//SPDX-License-1dentifier: LGPL-3.0-onlY
//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingApp is Ownable {
    //variables

    // 1. StakingToken address cuando inicialicemos necesitamos saber que token recibimos
    address public stakingToken;
    // 2. Admin con Ownabl

    // modificadores

    // eventos

    constructor(address stakingToken_, address owner_) Ownable(owner_) {
        stakingToken = stakingToken_;
    }

    // funciones externas

    // funciones internas
}
