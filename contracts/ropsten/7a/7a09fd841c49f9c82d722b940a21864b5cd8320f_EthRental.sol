pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




contract owned { //Contract used to only allow the owner to call some functions
	address public owner;

	function owned() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}


contract TokenERC20 {

	using SafeMath for uint256;
	// Public variables of the token
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	//
	uint256 public totalSupply;


	// This creates an array with all balances
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);

	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	* Constrctor function
	*
	* Initializes contract with initial supply tokens to the creator of the contract
	*/
	function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[this] = totalSupply;                // Give the contract all initial tokens
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
	}

	/**
	* Internal transfer, only can be called by this contract
	*/
	function _transfer(address _from, address _to, uint _value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check for overflows
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
		// Subtract from the sender
		balanceOf[_from] = balanceOf[_from].sub(_value);
		// Add the same to the recipient
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
	}

	/**
	* Function to Transfer tokens
	*
	* Send `_value` tokens to `_to` from your account
	*
	* @param _to The address of the recipient
	* @param _value the amount to send
	*/
	function transfer(address _to, uint256 _value) public returns (bool) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	* function to Transfer tokens from other address
	*
	* Send `_value` tokens to `_to` in behalf of `_from`
	*
	* @param _from The address of the sender
	* @param _to The address of the recipient
	* @param _value the amount to send
	*/
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		_transfer(_from, _to, _value);
		return true;
	}

	/**
	* function Set allowance for other address
	*
	* Allows `_spender` to spend no more than `_value` tokens in your behalf
	*
	* @param _spender The address authorized to spend
	* @param _value the max amount they can spend
	*/
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		return true;
	}


	/**
	*Function to Destroy tokens
	*
	* Remove `_value` tokens from the system irreversibly
	*
	* @param _value the amount of money to burn
	*/
	function burn(uint256 _value) public returns (bool success) {
		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
		totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}



	/**
	* Destroy tokens from other ccount
	*
	* Remove `_value` tokens from the system irreversibly on behalf of `_from`.
	*
	* @param _from the address of the sender
	* @param _value the amount of money to burn
	*/
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
		allowance[_from][msg.sender] =allowance[_from][msg.sender].sub(_value);             // Subtract from the sender&#39;s allowance
		totalSupply = totalSupply.sub(_value);                              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}


}

/******************************************/
/*       EthRental STARTS HERE       */
/******************************************/

contract EthRental is owned, TokenERC20  {

	//Modify these variables
	uint256 public sellPrice=1;
	uint256 public buyPrice=1;

	uint256 _initialSupply=1000000; 
	string _tokenName="EthRental";  
	string _tokenSymbol="ERT";

	mapping (address => mapping (address => bool)) public totalAllowance;

	/* Initializes contract with initial supply tokens to the creator of the contract */
	function EthRental( ) TokenERC20(_initialSupply, _tokenName, _tokenSymbol) public {}


	/// function to create more coins and send it to the contract
	/// @param mintedAmount the amount of tokens it will receive
	function mintToken(uint256 mintedAmount) onlyOwner public {
		balanceOf[this] = balanceOf[this].add(mintedAmount);
		totalSupply = totalSupply.add(mintedAmount);
		emit Transfer(0, this, mintedAmount);
	}

	function buy() payable public {
	  uint amount = msg.value / buyPrice;               // calculates the amount
	  _transfer(this, msg.sender, amount);              // makes the transfers
	}

	/// @notice Sell `amount` tokens to contract
	/// @param amount amount of tokens to be sold
	function sell(uint256 amount) public {
	  require(address(this).balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
	  _transfer(msg.sender, this, amount);              // makes the transfers
	  msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It&#39;s important to do this last to avoid recursion attacks
	}


	/**
	* function Set allowance for other address
	* Allows `_spender` to spend ALL YOUR TOKENS in your behalf
	* @param _spender The address authorized to spend
	**/
	function totalApproval(address _spender) public returns (bool success) {
		totalAllowance[msg.sender][_spender] = true;
		return true;
	}


	/**
	* function remove allowance for other address
	* Disallows `_spender` to spend all your tokens in your behalf
	* @param _spender The address unauthorized to spend
	**/
	function disapprove(address _spender) public returns (bool success) {
		totalAllowance[msg.sender][_spender] = false;
		return true;
	}


	/**
	* modified function to Transfer ANY AMOUNT OF TOKENS from other address only if authorized
	* Send `_value` tokens to `_to` in behalf of `_from`
	* @param _from The address of the sender
	* @param _to The address of the recipient
	* @param _value the amount to send
	*/
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if(!totalAllowance[_from][msg.sender]){
			allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		}
		_transfer(_from, _to, _value);
		return true;
	}

	function () payable public {
		buy();
	}


}