// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowdfundToken.sol";

contract CrowdfundDAO {
    CrowdfundToken public token;
    uint256 public quorum;
    uint256 public proposalCount;

    struct Proposal {
        uint256 id;
        string description;
        address payable recipient;
        uint256 amount;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 deadline;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 proposalId, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 proposalId);

    modifier hasTokens() {
        require(token.balanceOf(msg.sender) > 0, "No tokens, no vote");
        _;
    }

    constructor(address _token, uint256 _quorum) {
        token = CrowdfundToken(_token);
        quorum = _quorum;
    }

    function createProposal(
        string calldata _description,
        address payable _recipient,
        uint256 _amount,
        uint256 _votingDays
    ) external hasTokens returns (uint256) {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = _description;
        p.recipient = _recipient;
        p.amount = _amount;
        p.deadline = block.timestamp + (_votingDays * 1 days);
        emit ProposalCreated(proposalCount, _description);
        return proposalCount;
    }

    function vote(uint256 _proposalId, bool _support) external hasTokens {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.hasVoted[msg.sender], "Already voted");
        p.hasVoted[msg.sender] = true;
        uint256 weight = token.balanceOf(msg.sender);
        if (_support) p.votesFor += weight;
        else p.votesAgainst += weight;
        emit Voted(_proposalId, msg.sender, _support, weight);
    }

    function execute(uint256 _proposalId) external {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp >= p.deadline, "Voting still open");
        require(!p.executed, "Already executed");
        require(p.votesFor >= quorum, "Quorum not reached");
        require(p.votesFor > p.votesAgainst, "Proposal rejected");
        p.executed = true;
        p.recipient.transfer(p.amount);
        emit ProposalExecuted(_proposalId);
    }

    receive() external payable {}
}