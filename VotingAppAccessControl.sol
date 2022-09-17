// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.7;

/**
    Voting App
    1. App has 3 roles - ADMIN, MODERATOR & VOTER.
    2. ADMIN can:
        - Add/Remove Moderators/Voters.
        - Open/Close Voting.
        - Get & Withdraw Funds.
    3. MODERATOR can:
        - Add/Remove Voters.
        - Open/Close Voting.
    4. VOTER can:
        - Vote.

 */
contract VotingAppWithAccessControl {
    address payable public owner;
    bytes32 public ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 public MODERATOR = keccak256(abi.encodePacked("MODERATOR"));
    bytes32 public VOTER = keccak256(abi.encodePacked("VOTER"));
    mapping(bytes32 => mapping(address => bool)) hasRole;
    mapping(address => bool) whitelist;
    mapping(address => bool) hasVoted;
    uint votingFee = 1 ether;
    enum VotingStages { OPEN, CLOSED }
    VotingStages votingStage = VotingStages.CLOSED;
    
    constructor() {
        owner = payable(msg.sender);
        hasRole[ADMIN][owner] = true;
    }

    function addModerator(address _addr) public {
        require(hasRole[ADMIN][msg.sender] == true, "Not Authorized!");
        require(_addr != msg.sender, "Cannot update self role!");
        hasRole[MODERATOR][_addr] = true;
    }

    function removeModerator(address _addr) public {
        require(hasRole[ADMIN][msg.sender] == true, "Not Authorized!");
        require(_addr != msg.sender, "Cannot update self role!");
        hasRole[MODERATOR][_addr] = false;
    }

    function addVoter(address _addr) public {
        require(hasRole[ADMIN][msg.sender] == true || hasRole[MODERATOR][msg.sender] == true, "Not Authorized!");
        require(_addr != msg.sender, "Cannot update self role!");
        hasRole[VOTER][_addr] = true;
    }

    function removeVoter(address _addr) public {
        require(hasRole[ADMIN][msg.sender] == true || hasRole[MODERATOR][msg.sender] == true, "Not Authorized!");
        require(_addr != msg.sender, "Cannot update self role!");
        hasRole[VOTER][_addr] = false;
    }

    function openVoting() public {
        require(hasRole[ADMIN][msg.sender] == true || hasRole[MODERATOR][msg.sender] == true, "Not Authorized!");
        votingStage = VotingStages.OPEN;
    }

    function closeVoting() public {
        require(hasRole[ADMIN][msg.sender] == true || hasRole[MODERATOR][msg.sender] == true, "Not Authorized!");
        votingStage = VotingStages.CLOSED;
    }

    function vote() public payable {
        require(hasRole[VOTER][msg.sender] == true, "Not Authorized!");
        require(votingStage == VotingStages.OPEN, "Voting is closed!");
        require(hasVoted[msg.sender] == false, "You have already voted!");
        require(msg.value >= votingFee, "Need to send 1 ETH to vote!");
        hasVoted[msg.sender] = true;
    }

    function getFunds() public view returns(uint) {
        require(hasRole[ADMIN][msg.sender] == true, "Not Authorized!");
        return address(this).balance;
    }

    function withdrawFunds(uint _amount) public {
        require(hasRole[ADMIN][msg.sender] == true, "Not Authorized!");
        require(_amount <= address(this).balance, "Insufficient Funds!"); 
        owner.transfer(_amount);
    }
}
