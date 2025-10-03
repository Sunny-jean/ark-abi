// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ERC1155Token {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
     *
     * Emitted when tokens are created (`from` == address(0)) or destroyed (`to` == address(0)).
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Emitted when `value` amounts of tokens of type `ids` are transferred from `from` to `to` by `operator`.
     *
     * Emitted when tokens are created (`from` == address(0)) or destroyed (`to` == address(0)).
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to manage all of its tokens.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for a token `id` changes.
     */
    event URI(string value, uint256 indexed id);

    // Errors

    /**
     * @dev Thrown when a transfer amount exceeds the sender's balance for a specific token ID.
     */
    error InsufficientBalance(uint256 tokenId, uint256 available, uint256 required);

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a transfer is attempted to a zero address.
     */
    error TransferToZeroAddress();

    /**
     * @dev Thrown when a transfer is attempted from a non-owner or non-approved operator.
     */
    error TransferFromIncorrectOwner();

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens of each token type `ids` owned by `accounts`.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer all of the caller's tokens.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to manage all of `account`'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of `amount` of tokens of type `id`.
     * - If the caller is not `from`, it must be approved to move this token by {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     *   acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev Transfers `amounts` of tokens of type `ids` from `from` to `to`.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `ids` and `amounts` must have the same length.
     * - Each `from` account must have a balance of `amounts[i]` of tokens of type `ids[i]`.
     * - If the caller is not `from`, it must be approved to move this token by {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     *   acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

    /**
     * @dev Returns the URI for a given token ID.
     *
     * If the `_id` has a specific URI, it is returned. Otherwise, the contract's
     * default URI is returned, with `{id}` replaced by the token's ID.
     *
     * Requirements:
     *
     * - `id` must exist.
     */
    function uri(uint256 id) external view returns (string memory);
}