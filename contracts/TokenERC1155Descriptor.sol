// SPDX-License-Identifier: ISC

pragma solidity ^0.8.0;

contract TokenERC1155Descriptor {

  uint typesIndex;
  mapping(uint => uint) idToMaxSupply;
  mapping(uint => bool) idToExist;

  constructor() {
  }

  function addTypeToken(uint _maxSupply) public virtual {
    uint idTokenToAdd = typesIndex;

    typesIndex += 1;
    idToMaxSupply[idTokenToAdd] = _maxSupply;
    idToExist[idTokenToAdd] = true;
  }

  function getMaxSupplyByTypeId(uint _id) public view virtual returns(uint) {
    require(idToExist[_id] == true, "TokenERC1155Descriptor: query id not exist");

    return idToMaxSupply[_id];
  }
}

