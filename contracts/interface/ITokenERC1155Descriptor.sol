// SPDX-License-Identifier: ISC

pragma solidity ^0.8.0;

interface ITokenERC1155Descriptor {

  function addTypeToken(uint _maxSupply) external;

  function getMaxSupplyByTypeId(uint _id) external view returns(uint);

}

