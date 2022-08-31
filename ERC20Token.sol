pragma solidity ^0.4.24;
 
//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 
 
//ERC Token Standard #20 Interface
 
contract ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;
    
    function totalSupply() public constant returns (uint);
    function balanceOf(address _tokenOwner) public view returns (uint);
    function allowance(address _tokenOwner, address _spender) public view returns (uint);
    function approve(address _spender, uint _tokens) public returns (bool);
    function transfer(address _to, uint _tokens) public returns (bool);
    function transferFrom(address _from, address _to, uint _tokens) public returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 

//Actual token contract
 
contract ERC20Token is ERC20Interface, SafeMath {
    address public owner;
    uint _totalSupply;
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;

    constructor() public {
        symbol = "SREEK";
        name = "Sreekar Coin";
        decimals = 0;
        owner = msg.sender;
        _totalSupply = 24;
        balances[owner] = _totalSupply;
    }

    function totalSupply() public constant returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address _tokenOwner) public view returns (uint) {
        return balances[_tokenOwner];
    }

    function allowance(address _tokenOwner, address _spender) public view returns (uint) {
        return allowed[_tokenOwner][_spender];
    }

    function approve(address _spender, uint _tokens) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _tokens);
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferHelper(address _from, address _to, uint _tokens) internal {
        balances[_from] = safeSub(balances[_from], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        emit Transfer(_from, _to, _tokens);
    }

    function transfer(address _to, uint _tokens) public returns (bool) {
        require(balanceOf(msg.sender) >= _tokens, "Insufficient Tokens!");
        transferHelper(msg.sender, _to, _tokens);
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public returns (bool) {
        require(allowance(_from, msg.sender) != 0, "No Token Allowance!");
        require(allowance(_from, msg.sender) >= _tokens, "Insufficient Token Allowance!");
        require(balanceOf(_from) >= _tokens, "Insufficient Tokens!");
        transferHelper(_from, _to, _tokens);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _tokens);
        return true;
    }
}
