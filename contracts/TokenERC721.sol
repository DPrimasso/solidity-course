// SPDX-License-Identifier: ISC

// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./interface/IERC721.sol";
import "./Context.sol";
import "./utils/Strings.sol";

// ERC721 -> fD65790
// ERC20 -> xxxx
/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract TokenERC721 is Context{
  using Strings for uint256;

  /**
   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
   */
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
   */
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
   */
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  // Mapping owner address to token count
  mapping(address => uint256) private _balances;

  // Mapping from token ID to approved address
  mapping(uint256 => address) private _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  // Mapping from token ID to owner address
  mapping(uint256 => address) private _owners;

  string _name;
  string _symbol;

  string public baseURI;
  // Optional mapping for token URIs
  mapping(uint => string) private _tokenURIs;

  /**
 * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
 */
  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  /**
       * @dev Mints `tokenId` and transfers it to `to`.
       *
       * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
       *
       * Requirements:
       *
       * - `tokenId` must not exist.
       * - `to` cannot be the zero address.
       *
       * Emits a {Transfer} event.
       */
  function mint(address to, uint256 tokenId, string memory _tokenURI) public {
    // require msgSender == ownerContract // MINTER del contratto

    require(to != address(0), "ERC721: mint to the zero address");
    require(!_exists(tokenId), "ERC721: token already minted");

    _balances[to] += 1;
    _owners[tokenId] = to;

    _setTokenURI(tokenId, _tokenURI);

    emit Transfer(address(0), to, tokenId);
  }

  function setTokenURI(uint _tokenId, string memory _tokenURI) public {
    require(_exists(_tokenId), "COCNFTManager: URI set of nonexistent token");
    _setTokenURI(_tokenId, _tokenURI);
  }

  /**
     * @dev Internal function to set the token URI for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     * TIP: If all token IDs share a prefix (for example, if your URIs look like
     * `https://api.myproject.com/token/<id>`), use {_setBaseURI} to store
     * it and save gas.
     */
  function _setTokenURI(uint _tokenId, string memory _tokenURI) internal virtual {
    _tokenURIs[_tokenId] = _tokenURI;
  }

  /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
  function tokenURI(uint _tokenId) public view virtual returns (string memory) {
    require(_exists(_tokenId), "ERC721: URI query for nonexistent token");

    string memory tokenUri = _tokenURIs[_tokenId];

    // If there is no base URI, return the token URI.
    if (bytes(baseURI).length == 0) {
      return tokenUri;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(tokenUri).length > 0) {
      return string(abi.encodePacked(baseURI, tokenUri));
    }
    // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
    return string(abi.encodePacked(baseURI, _tokenId.toString()));
  }

  /**
 * @dev Set the baseURI for the tokenURIs.
 * Note that this function is supposed to be called only by the ADMIN
 */
  function setBaseURI(string memory _prefix) public {
    baseURI = _prefix;
  }

  /**
   * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overriden in child contracts.
   */
  function _baseURI() internal view virtual returns (string memory) {
    return "ipfs://";
  }

  /**
   * @dev Returns whether `tokenId` exists.
   *
   * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
   *
   * Tokens start existing when they are minted (`_mint`),
   * and stop existing when they are burned (`_burn`).
   */
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _owners[tokenId] != address(0);
  }

  /**
   * @dev See {IERC721-balanceOf}.
   */
  function balanceOf(address owner) public view virtual returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _balances[owner];
  }

  /**
   * @dev See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId) public view virtual returns (address) {
    address owner = _owners[tokenId];
    require(owner != address(0), "ERC721: owner query for nonexistent token");
    return owner;
  }

  /**
   * @dev See {IERC721Metadata-name}.
   */
  function name() public view virtual returns (string memory) {
    return _name;
  }

  /**
   * @dev See {IERC721Metadata-symbol}.
   */
  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  /**
   * @dev See {IERC721-approve}.
   */
  function approve(address to, uint256 tokenId) public virtual {
    address owner = ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");

    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721: approve caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  /**
   * @dev Approve `to` to operate on `tokenId`
   *
   * Emits a {Approval} event.
   */
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(ownerOf(tokenId), to, tokenId);
  }

  /**
   * @dev See {IERC721-getApproved}.
   */
  function getApproved(uint256 tokenId) public view virtual returns (address) {
    require(_exists(tokenId), "ERC721: approved query for nonexistent token");

    return _tokenApprovals[tokenId];
  }

  /**
   * @dev See {IERC721-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved) public virtual {
    _setApprovalForAll(_msgSender(), operator, approved);
  }

  /**
   * @dev Approve `operator` to operate on all of `owner` tokens
   *
   * Emits a {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC721: approve to caller");
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @dev See {IERC721-isApprovedForAll}.
   */
  function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
    return _operatorApprovals[owner][operator];
  }

  /**
   * @dev See {IERC721-transferFrom}.
   */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    //solhint-disable-next-line max-line-length
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

    _transfer(from, to, tokenId);
  }

  /**
 * @dev Transfers `tokenId` from `from` to `to`.
 *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
 *
 * Requirements:
 *
 * - `to` cannot be the zero address.
 * - `tokenId` token must be owned by `from`.
 *
 * Emits a {Transfer} event.
 */
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {

    require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
    require(to != address(0), "ERC721: transfer to the zero address");

    //_beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);

    //_afterTokenTransfer(from, to, tokenId);
  }


  /**
   * @dev Returns whether `spender` is allowed to manage `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    address owner = ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    _safeTransfer(from, to, tokenId, "");
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    _safeTransfer(from, to, tokenId, _data);
  }

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * `_data` is additional data, it has no specified format and it is sent in call to `to`.
   *
   * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
   * implement alternative mechanisms to perform token transfer, such as signature-based.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function _safeTransfer(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) internal virtual {
    _transfer(from, to, tokenId);
    //require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
  }

}
