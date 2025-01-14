/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract CodeWithNeon is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "CodeWithNeon";
        symbol = "NEN";
        decimals = 18;
        _totalSupply = 1000000000000000000000000000;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        // require(balances[msg.sender] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0);
        
        uint burnAmount = tokens / 100; // сжигаемая сумма
        uint tokensSent = tokens - burnAmount;  // перечисляемая сумма
        _totalSupply = _totalSupply - tokens;
        
        balances[msg.sender] = safeSub(balances[msg.sender], tokens); // снимается tokens
        balances[to] = safeAdd(balances[to], tokensSent); // добавляется tokensSent
        emit Transfer(msg.sender, to, tokensSent); // подтверждение
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // require(balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0);
        
        uint burnAmount = tokens / 100; 
        uint tokensSent = tokens - burnAmount; 
        _totalSupply = _totalSupply - tokens;
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokensSent);
        emit Transfer(from, to, tokensSent);
        return true;
    }
    
        /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    /*function burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        // transferFrom(account, address(0), amount); // перечисление на "нулевой" адрес (сжигание)
        
        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        balances[account] = accountBalance - amount; // уменьшение баланса с которого переводятся средства
        totalSupply -= amount; // уменьшение общего оборота средств (удаление из оборота)

        emit Transfer(account, address(0), amount);
    }*/
    
}