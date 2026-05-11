contract Token {
    mapping(address => uint) public balances;

    event Transferencia(address indexed from, uint amount, address to);

    function transferir(address to, uint amount) public {
        require(balances[msg.sender] >= amount, "Saldo insuficiente");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transferencia(msg.sender, amount, to);
    }
}
