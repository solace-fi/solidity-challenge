// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
  constructor() ERC20("Antonio Token", "ATO") {
    _mint(msg.sender, 100 * 10**18);
  }
  
}