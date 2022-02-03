// SPDX-License-Identifier: ISC

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interface/ITokenERC1155Descriptor.sol";

contract TokenERC1155Manager is IERC1155, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  using Address for address;

  mapping(uint => mapping(address => uint)) tokenToAddressToBalance;
  mapping(uint => uint) tokenIdToSupply;

  ITokenERC1155Descriptor tokenErc1155;
  /*
  0 => 0x1 => 1000
       0x2 => 500
  1 => 0x1 => 10
       0x3 => 5000
}
  0x1 => 1 => 1000
         2 => 32000
  0x...100000 0 =>
  */

  constructor(address _tokenDescriptor) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    tokenErc1155 = ITokenERC1155Descriptor(_tokenDescriptor);

  }

  function changeTokenDescriptor(address _tokenDescriptor) public onlyRole(DEFAULT_ADMIN_ROLE) virtual {
    tokenErc1155 = ITokenERC1155Descriptor(_tokenDescriptor);
  }

  function mint(address _to, uint _id, uint _amount, bytes memory _data) public onlyRole(MINTER_ROLE) virtual {
    // amount non superi la supply massima impostata per l'id
    require((tokenErc1155.getMaxSupplyByTypeId(_id) == 0 || tokenErc1155.getMaxSupplyByTypeId(_id) > tokenIdToSupply[_id] + _amount), "TokenERC1155Manager: supply over");

    _mint(_to, _id, _amount, _data);
    tokenIdToSupply[_id] += _amount;
  }

  /**
   * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
   *
   * Emits a {TransferSingle} event.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
   * acceptance magic value.
   */
  function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
    require(to != address(0), "TokenERC1155: cannot mint to the zero address");

    address operator = _msgSender();

    _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

    tokenToAddressToBalance[id][to] += amount;

    emit TransferSingle(operator, address(0), to, id, amount);

    _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
  }

  function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) public onlyRole(MINTER_ROLE) virtual {
    // amount non superi la supply massima impostata per l'id

    _mintBatch(_to, _ids, _amounts, _data);
  }

  /**
 * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
 *
 * Requirements:
 *
 * - `ids` and `amounts` must have the same length.
 * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
 * acceptance magic value.
 */
  function _mintBatch(
    address _to,
    uint256[] memory _ids,
    uint256[] memory _amounts,
    bytes memory _data
  ) internal virtual {
    require(_to != address(0), "ERC1155: mint to the zero address");
    require(_ids.length == _amounts.length, "ERC1155: ids and amounts length mismatch");

    address operator = _msgSender();

    _beforeTokenTransfer(operator, address(0), _to, _ids, _amounts, _data);

    for (uint256 i = 0; i < _ids.length; i++) {
      require((
        tokenErc1155.getMaxSupplyByTypeId(_ids[i]) == 0 ||
        tokenErc1155.getMaxSupplyByTypeId(_ids[i]) > tokenIdToSupply[_ids[i]] + _amounts[i]),
        "TokenERC1155Manager: supply over");

      tokenToAddressToBalance[_ids[i]][_to] += _amounts[i];
    }

    emit TransferBatch(operator, address(0), _to, _ids, _amounts);

    _doSafeBatchTransferAcceptanceCheck(operator, address(0), _to, _ids, _amounts, _data);
  }


  function balanceOf(address _account, uint _id) public view override returns (uint) {
    require(_account != address(0), "ERC1155: balance query for the zero address");

    return tokenToAddressToBalance[_id][_account];
  }

  function balanceOfBatch(address[] memory _accounts, uint[] memory _ids) public view virtual override returns (uint[] memory) {
    require(_accounts.length == _ids.length, "ERC1155: accounts and ids length mismatch");

    uint[] memory batchBalances = new uint[](_ids.length);

    for(uint8 i = 0; i < _accounts.length; i++) {
      batchBalances[i] = balanceOf(_accounts[i], _ids[i]);
    }

    return batchBalances;
  }

  function setApprovalForAll(address operator, bool approved) public virtual override {}

  function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {}

  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {}

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override {}

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view override(AccessControl, IERC165) virtual returns (bool) {
    return
    interfaceId == type(IERC1155).interfaceId;
    //|| interfaceId == type(IERC1155MetadataURI).interfaceId;
  }

  /**
 * @dev Hook that is called before any token transfer. This includes minting
 * and burning, as well as batched variants.
 *
 * The same hook is called on both single and batched variants. For single
 * transfers, the length of the `id` and `amount` arrays will be 1.
 *
 * Calling conditions (for each `id` and `amount` pair):
 *
 * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
 * of token type `id` will be  transferred to `to`.
 * - When `from` is zero, `amount` tokens of token type `id` will be minted
 * for `to`.
 * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
 * will be burned.
 * - `from` and `to` are never both zero.
 * - `ids` and `amounts` have the same, non-zero length.
 *
 * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
 */
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual {}

  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = element;

    return array;
  }

  function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) private {
    if (to.isContract()) {
      try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
        if (response != IERC1155Receiver.onERC1155Received.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }


  function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) private {
    if (to.isContract()) {
      try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
        bytes4 response
      ) {
        if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
          revert("ERC1155: ERC1155Receiver rejected tokens");
        }
      } catch Error(string memory reason) {
        revert(reason);
      } catch {
        revert("ERC1155: transfer to non ERC1155Receiver implementer");
      }
    }
  }

}

