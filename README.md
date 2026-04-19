## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Proyecto: Staking App

Este repositorio contiene una aplicación simple de staking con dos contratos principales:

- `src/StakingToken.sol`: un token ERC20 simple que permite mintar tokens para pruebas.
- `src/StakingApp.sol`: un contrato de staking donde los usuarios depositan un monto fijo y pueden reclamar recompensas en ETH.

### Cómo funciona el staking

1. El usuario aprueba al contrato `StakingApp` para gastar su `StakingToken`.
2. El usuario llama a `depositTokens` con el monto fijo configurado.
3. El contrato actualiza el índice global de recompensas y guarda el depósito del usuario.
4. Las recompensas se acumulan en función del tiempo total stakeado y del `rewardRate`.
5. El usuario puede retirar todos sus tokens con `witdrawTokens`.
6. El usuario puede reclamar las recompensas en ETH con `claimRewards` después de esperar el `stakingPeriod`.

### Contratos importantes

- `StakingToken`: ERC20 simple que permite mint a cualquier dirección.
- `StakingApp`: maneja el staking de tokens ERC20, el cálculo de recompensas y el pago en ETH.

### Tests

Los tests se encuentran en `test/StakingTest.sol` y `test/StakingTokenTest.t.sol`.

- `StakingTest.sol`: comprueba el comportamiento del staking, incluidos depósitos, retiros y reclamación de recompensas.
- `StakingTokenTest.t.sol`: verifica que el token mint funciona correctamente.

## Cómo documentar este proyecto

1. Lee el código primero y entiende qué hace cada contrato.
2. Identifica las responsabilidades principales: qué hace cada función y qué variables guarda el estado.
3. Agrega comentarios claros en el código.
   - Usa `/// @notice` para explicar qué hace una función.
   - Usa `/// @dev` para anotar detalles de implementación.
4. Mantén actualizado el README con:
   - la arquitectura del proyecto,
   - los contratos principales,
   - los comandos para probar y compilar.
5. Revisa las pruebas y documenta cada escenario importante.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Anvil

```shell
$ anvil
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
