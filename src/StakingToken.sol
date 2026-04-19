// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title StakingToken
/// @notice Token ERC20 simple que permite la mint de tokens por cualquier cuenta.
/// @dev Este contrato se utiliza principalmente para pruebas del sistema de staking.
contract StakingToken is ERC20 {
    /// @param name_ Nombre del token.
    /// @param symbol_ Símbolo del token.
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    /// @notice Genera nuevos tokens y los asigna a la dirección que llama.
    /// @dev No hay restricciones de acceso; esta función es solo para pruebas.
    /// @param amount_ Cantidad de tokens a mint.
    function mint(uint256 amount_) external {
        _mint(msg.sender, amount_);
    }
}
