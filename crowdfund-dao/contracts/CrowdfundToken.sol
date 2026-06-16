// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdfundToken is ERC20, Ownable {
    constructor() ERC20("CrowdToken", "CRT") Ownable(msg.sender) {}

    // Only the Campaign contract (owner) can mint
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}