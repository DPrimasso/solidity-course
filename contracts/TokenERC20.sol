// SPDX-License-Identifier: ISC

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/AccessControl.sol";
import "./Context.sol";

contract TokenERC20 is ERC20 {

  address owner;

  modifier onlyOwner {
    require(_msgSender() == owner, "error");
    _;
  }

  constructor(uint initialBalance) {
    _mint(initialBalance);
    owner = _msgSender();
  }

  function mint(address to, uint amount) onlyOwner public {
    _mint(to, amount);
  }

  // logic
  // reflection
  // tax transfer -> override transfer, e poi richiami la transfer interna
  //

}
