// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowdfundToken.sol";

contract CrowdfundCampaign {
    CrowdfundToken public token;
    address public owner;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalRaised;
    bool public goalReached;

    mapping(address => uint256) public contributions;

    event Funded(address indexed contributor, uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);
    event GoalReached(uint256 totalRaised);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier campaignActive() {
        require(block.timestamp < deadline, "Campaign ended");
        require(!goalReached, "Goal already reached");
        _;
    }

    constructor(address _token, uint256 _goal, uint256 _durationDays) {
        token = CrowdfundToken(_token);
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationDays * 1 days);
    }

    function fund() external payable campaignActive {
        require(msg.value > 0, "Send ETH to fund");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        // 1 ETH = 100 tokens
        token.mint(msg.sender, msg.value * 100);
        emit Funded(msg.sender, msg.value);

        if (totalRaised >= goal) {
            goalReached = true;
            emit GoalReached(totalRaised);
        }
    }

    function refund() external {
        require(block.timestamp >= deadline, "Campaign still active");
        require(!goalReached, "Goal was reached, no refunds");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "Nothing to refund");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refunded(msg.sender, amount);
    }

    function withdraw() external onlyOwner {
        require(goalReached, "Goal not reached");
        payable(owner).transfer(address(this).balance);
    }
}