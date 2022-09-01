// SPDX-License-Identifier: MIT
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
 
 
//ERC Token Standard #721 Interfaces
 
contract ERC721Interface {

    function balanceOf(address _owner) public view returns (uint);
    function ownerOf(uint _tokenId) public view returns (address);
    function safeTransferFrom(address _from, address _to, uint _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes _data) public;
    function transferFrom(address _from, address _to, uint _tokenId) public;
    function approve(address _to, uint _tokenId) public;
    function getApproved(uint _tokenId) public returns (address);
    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public returns (bool);

    event Approval(address owner, address approved, uint tokenId);
    event ApprovalForAll(address owner, address operator, bool approved);
    event Transfer(address from, address to, uint tokenId);

}

contract ERC721MetadataInterface {
    
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function tokenURI(uint _tokenId) public view returns (string memory);

}

contract ERC721ReceiverInterface {
    
    function onERC721Received(address _operator, address _from, uint _tokenId, bytes _data) external returns (bytes calldata);

}
 

//Actual token contract
 
contract ERC721Token is ERC721Interface, ERC721MetadataInterface, SafeMath {

    address owner;
    string _name;
    string _symbol;
    mapping (address => uint) balances;
    mapping (uint => address) owners;
    mapping (uint => address) tokenOperators;
    mapping (address => address) ownerOperators;
    uint nextMint = 0;
    uint maxMints;

    constructor() public {
        owner = msg.sender;
        _name = "Sreekar NFT";
        _symbol = "SNFT";
        maxMints = 10;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function ownerOf(uint _tokenId) public view returns (address) {
        require(_exists(_tokenId), "Token does not exist!");
        return owners[_tokenId];
    }

    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function tokenURI(uint _tokenId) public view returns (string memory) {
        require(_exists(_tokenId), "Token does not exist!");
        return "";
    }

    function approve(address _to, uint _tokenId) public {
        require(msg.sender == owners[_tokenId] || msg.sender == ownerOperators[owners[_tokenId]], "Cannot approve since you are not owner or approved operator!");
        require(_to != msg.sender, "Cannot approve self!");
        require(_exists(_tokenId), "Token does not exist!");
        tokenOperators[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function getApproved(uint _tokenId) public returns (address) {
        require(_exists(_tokenId), "Token does not exist!");
        return tokenOperators[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender, "Cannot approve self!");
        if (_approved) {
            ownerOperators[msg.sender] = _operator;
        } else {
            ownerOperators[msg.sender] = address(0);
        }
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public returns (bool) {
        return ownerOperators[_owner] == _operator;
    }

    function transferFrom(address _from, address _to, uint _tokenId) public {
        require(_from != address(0), "Owner cannot be 0x000!");
        require(_to != address(0), "Receiver cannot be 0x000!");
        require(owners[_tokenId] == _from, "Not the Owner!");
        require(_canAccessToken(msg.sender, _tokenId), "Not Authorized!");
        owners[_tokenId] = _to;
        balances[_from] = safeSub(balances[_from], 1);
        balances[_to] = safeAdd(balances[_to], 1);
        tokenOperators[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) public {
        // TODO : CHECK SAFE TRANSFER
        transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes _data) public {
        // TODO : CHECK SAFE TRANSFER
        transferFrom(_from, _to, _tokenId);
    }

    function _exists(uint _tokenId) internal view returns (bool) {
        return _tokenId < nextMint;
    }

    function _canAccessToken(address _accessor, uint _tokenId) internal view returns (bool) {
        return owners[_tokenId] == _accessor || tokenOperators[_tokenId] == _accessor || ownerOperators[owners[_tokenId]] == _accessor;
    }

    function _mint(address _to, uint _tokenId) internal {
        require(_to != address(0), "Receiver cannot be 0x000!");
        require(owners[_tokenId] == address(0), "Cannot be minted!");
        owners[_tokenId] = _to;
        balances[_to] = safeAdd(balances[_to], 1);
        tokenOperators[_tokenId] = address(0);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _safeMint(address _to, uint _tokenId) internal {
        // TODO : CHECK SAFE TRANSFER
        _mint(_to, _tokenId);
    }

    function _safeMint(address _to, uint _tokenId, bytes _data) internal {
        // TODO : CHECK SAFE TRANSFER
        _mint(_to, _tokenId);
    }

    function mintNext(address _to) public {
        require(msg.sender == owner, "Not Authorized!");
        require(nextMint < maxMints, "No more can be minted!");
        _safeMint(_to, nextMint);
        nextMint = safeAdd(nextMint, 1);
    }
}
