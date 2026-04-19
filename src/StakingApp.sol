// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

error NotIsValueAcceptError();
error InsufficientBalance();
error NeedToWaitRewardError();
error TransferFailed();

/// @title StakingApp
/// @notice Permite a los usuarios depositar un token ERC20 para staking y reclamar recompensas en ETH.
/// @dev El contrato usa un índice global de rewardPerToken para repartir recompensas proporcionales al staking.
contract StakingApp is Ownable {
    /// @notice Token ERC20 que se aceptará como stake.
    address public stakingToken;

    /// @notice Tiempo mínimo en segundos que debe pasar entre reclamos de recompensas.
    uint256 public stakingPeriod;

    /// @notice Cantidad fija de tokens que cada usuario debe depositar para habilitar staking.
    uint256 public fixedStakingAmount;

    /// @notice Recompensa distribuida por segundo para todos los stakers.
    uint256 public rewardRate;

    /// @notice Última marca de tiempo a la que se actualizó el índice global de recompensas.
    uint256 public lastUpdateTime;

    /// @notice Índice acumulado de reward por token.
    uint256 public rewardPerTokenStored;

    /// @notice Total de tokens stakeados actualmente en el contrato.
    uint256 public tokenStored;

    /// @notice Monto de tokens depositado por cada usuario.
    mapping(address => uint256) private balances;

    /// @notice Marca de tiempo de la última operación relevante de cada usuario.
    mapping(address => uint256) private publicTime;

    /// @notice Recompensa pendiente acumulada por cada usuario.
    mapping(address => uint256) public reward;

    /// @notice Índice de reward por token que ya fue pagado para cada usuario.
    mapping(address => uint256) public userRewardPerTokenPaid;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address indexed userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address indexed userAddress_);
    event EtherReceived(uint256 amount_);

    /// @param stakingToken_ Dirección del token ERC20 que se utilizará para staking.
    /// @param owner_ Dirección del propietario inicial del contrato.
    /// @param stakingPeriod_ Periodo mínimo en segundos para poder reclamar recompensas.
    /// @param fixedStakingAmount_ Cantidad fija de tokens que el usuario debe depositar.
    /// @param rewardRate_ Monto de recompensa que se acumula por segundo.
    constructor(
        address stakingToken_,
        address owner_,
        uint256 stakingPeriod_,
        uint256 fixedStakingAmount_,
        uint256 rewardRate_
    ) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardRate = rewardRate_;
        lastUpdateTime = block.timestamp;
    }

    /// @dev Verifica que el usuario tenga al menos el monto mínimo stakeado requerido.
    modifier checkClaimRewards() {
        if (balances[msg.sender] < fixedStakingAmount)
            revert InsufficientBalance();
        _;
    }

    /// @dev Verifica que el usuario tenga saldo depositado antes de retirar.
    modifier checkBalance() {
        if (balances[msg.sender] <= 0) revert InsufficientBalance();
        _;
    }

    /// @dev Actualiza el índice global de recompensas y el estado de rewards del usuario.
    modifier updateRewardEarnad(address user_) {
        rewardPerTokenStored = claimRewardsPerSeconds();
        lastUpdateTime = block.timestamp;

        if (user_ != address(0)) {
            reward[user_] = earned(user_);
            userRewardPerTokenPaid[user_] = rewardPerTokenStored;
        }
        _;
    }

    /// @notice Cambia el periodo mínimo de reclamo de recompensas.
    /// @dev Función accesible solo por el propietario.
    /// @param newStakingPeriod_ Nuevo valor del periodo en segundos.
    function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    /// @notice Deposita la cantidad fija de tokens y activa el staking para el usuario.
    /// @dev El usuario debe aprobar antes el contrato para gastar el token.
    /// @param tokenAmountToDeposit_ Cantidad de tokens a depositar; debe ser igual a fixedStakingAmount.
    function depositTokens(
        uint256 tokenAmountToDeposit_
    ) external updateRewardEarnad(msg.sender) {
        if (tokenAmountToDeposit_ != fixedStakingAmount)
            revert NotIsValueAcceptError();

        IERC20(stakingToken).transferFrom(
            msg.sender,
            address(this),
            tokenAmountToDeposit_
        );
        balances[msg.sender] += tokenAmountToDeposit_;
        tokenStored += tokenAmountToDeposit_;
        publicTime[msg.sender] = block.timestamp;

        emit DepositTokens(msg.sender, tokenAmountToDeposit_);
    }

    /// @notice Retira todos los tokens stakeados por el usuario.
    /// @dev Actualiza rewards antes de transferir los tokens.
    function witdrawTokens()
        external
        checkBalance
        updateRewardEarnad(msg.sender)
    {
        uint256 userBalance_ = balances[msg.sender];
        balances[msg.sender] -= userBalance_;
        tokenStored -= userBalance_;

        emit WithdrawTokens(msg.sender);
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
    }

    /// @notice Reclama la recompensa en ETH acumulada por el usuario.
    /// @dev El contract debe contener saldo ETH suficiente para pagar la recompensa.
    function claimRewards()
        external
        checkClaimRewards
        updateRewardEarnad(msg.sender)
    {
        uint256 elapsePeriod_ = block.timestamp - publicTime[msg.sender];
        if (elapsePeriod_ < stakingPeriod) revert NeedToWaitRewardError();

        publicTime[msg.sender] = block.timestamp;
        uint256 rewardUser = reward[msg.sender];
        reward[msg.sender] -= rewardUser;

        (bool success, ) = msg.sender.call{value: rewardUser}("");
        if (!success) revert TransferFailed();
    }

    /// @notice Calcula el índice actualizado de reward por token.
    /// @dev Si no hay tokens stakeados, devuelve el índice almacenado.
    function claimRewardsPerSeconds() public view returns (uint256) {
        if (tokenStored == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
            tokenStored;
    }

    /// @notice Devuelve la recompensa total ganada por un usuario en este momento.
    /// @param user_ Dirección del usuario.
    function earned(address user_) public view returns (uint256) {
        return
            ((balances[user_] *
                (claimRewardsPerSeconds() - userRewardPerTokenPaid[user_])) /
                1e18) + reward[user_];
    }

    /// @notice Devuelve el periodo de staking configurado.
    function getStakingPeriod() public view returns (uint256) {
        return stakingPeriod;
    }

    /// @notice Recibe ETH para que el contrato pueda pagar recompensas.
    receive() external payable {
        emit EtherReceived(msg.value);
    }

    /// @notice Función vacía definida como placeholder para extensiones futuras.
    function updateReward() internal {}

    /// @notice Devuelve el balance de tokens stakeados del remitente.
    function getBalanceUser() public view returns (uint256) {
        return balances[msg.sender];
    }
}
