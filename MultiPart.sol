//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;
contract MultiPart {

    address public admin;
    uint256 public minWin;
    uint256 public totalProposal;
    uint256 public totalOwner;
    mapping(address=>bool) public isOwner;
    mapping(uint256=>mapping(address=>bool)) public supportStatus; 
    //0=no response, 1= positive, 2 = negative
    
    struct Proposal{
        string proposal;
        uint256 support;
        address by;
        bool status; //false = pendinf, true = successful
    }
    event ProposalMade(string proposal_, address by);
    mapping(uint256=>Proposal) public proposal;

    constructor() {
        admin = msg.sender;
    }
    function addOwner(address wallet) public {
        require(msg.sender == admin);
        totalOwner +=1;
        isOwner[wallet] = true;
    }
    function removeOwner(address wallet) public {
        require(msg.sender == admin);
        totalOwner -=1;
        isOwner[wallet] = false;
    }

    function setMinWin(uint256 min) public {
        require(msg.sender == admin);
        minWin = min;
    }

    function makeProposal(string calldata proposal_ ) public {
        require(isOwner[msg.sender] == true, "You are not owner");
        totalProposal += 1;
        proposal[totalProposal] = Proposal(proposal_, 0, msg.sender, false);
        emit ProposalMade(proposal_, msg.sender);
    }
    /* 
    support uint256 0 = no response, 1 = support, 2 = against
     */
    function addSupport(uint256 proposalId) public {
        require(isOwner[msg.sender] == true,  "You are not owner");
        require(proposal[proposalId].status == false, "Already Executed");
        require(proposal[proposalId].by != msg.sender, "You are owner and cannot vote");
        require(supportStatus[proposalId][msg.sender] == false, "Already Voted");
        supportStatus[proposalId][msg.sender] = true;
        proposal[proposalId].support +=1;
    }

    function executeProposal(uint256 proposalId) public {
        require(proposal[proposalId].status == false, "Already Executed");
        require(proposal[proposalId].by == msg.sender);
        uint256 supportGot = proposal[proposalId].support;
        uint256 supportPer = (supportGot * 100) / totalOwner;
        require(supportPer>=(minWin), "Minimum Support is not reached");
        proposal[proposalId].status = true;
    }

    

}
