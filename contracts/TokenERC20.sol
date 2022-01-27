// SPDX-License-Identifier: ISC

// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// ERC721 -> fD65790
// ERC20 -> xxxx
/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract TokenERC20 is ERC20, AccessControl{
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor() ERC20("TokenERC20", "TK20") {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function mint(address _to, uint _amount) public onlyRole(MINTER_ROLE) returns(bool) {
    _mint(_to, _amount);
    return true;
  }



}
