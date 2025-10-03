// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface VirtualEconomy {
    /**
     * @dev Emitted when in-game currency is minted.
     * @param currencyId The ID of the currency.
     * @param to The address to which the currency is minted.
     * @param amount The amount of currency minted.
     */
    event CurrencyMinted(bytes32 indexed currencyId, address indexed to, uint256 amount);

    /**
     * @dev Emitted when in-game currency is transferred.
     * @param currencyId The ID of the currency.
     * @param from The address from which the currency is transferred.
     * @param to The address to which the currency is transferred.
     * @param amount The amount of currency transferred.
     */
    event CurrencyTransferred(bytes32 indexed currencyId, address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Emitted when in-game currency is burned.
     * @param currencyId The ID of the currency.
     * @param from The address from which the currency is burned.
     * @param amount The amount of currency burned.
     */
    event CurrencyBurned(bytes32 indexed currencyId, address indexed from, uint256 amount);

    /**
     * @dev Emitted when an in-game item is purchased.
     * @param buyer The address of the buyer.
     * @param itemId The ID of the item purchased.
     * @param currencyId The ID of the currency used.
     * @param price The price paid for the item.
     */
    event ItemPurchased(address indexed buyer, bytes32 indexed itemId, bytes32 indexed currencyId, uint256 price);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a currency with the given ID is not found.
     */
    error CurrencyNotFound(bytes32 currencyId);

    /**
     * @dev Thrown when an item with the given ID is not found or not available for purchase.
     */
    error ItemNotAvailable(bytes32 itemId);

    /**
     * @dev Thrown when the buyer has insufficient currency balance.
     */
    error InsufficientCurrency(bytes32 currencyId, address holder, uint256 requested, uint256 available);

    /**
     * @dev Thrown when the price of an item does not match the expected price.
     */
    error PriceMismatch(uint256 expected, uint256 provided);

    /**
     * @dev Mints new in-game currency and assigns it to a player.
     * Only callable by authorized game contracts or administrators.
     * @param currencyId The ID of the currency to mint.
     * @param to The address to which the currency will be minted.
     * @param amount The amount of currency to mint.
     */
    function mintCurrency(bytes32 currencyId, address to, uint256 amount) external;

    /**
     * @dev Transfers in-game currency from one player to another.
     * @param currencyId The ID of the currency to transfer.
     * @param from The address from which to transfer currency.
     * @param to The address to which to transfer currency.
     * @param amount The amount of currency to transfer.
     */
    function transferCurrency(bytes32 currencyId, address from, address to, uint256 amount) external;

    /**
     * @dev Burns in-game currency from a player's balance.
     * Only callable by authorized game contracts or administrators.
     * @param currencyId The ID of the currency to burn.
     * @param from The address from which to burn currency.
     * @param amount The amount of currency to burn.
     */
    function burnCurrency(bytes32 currencyId, address from, uint256 amount) external;

    /**
     * @dev Allows a player to purchase an in-game item using a specified currency.
     * @param itemId The ID of the item to purchase.
     * @param currencyId The ID of the currency to use for payment.
     * @param price The price of the item.
     */
    function purchaseItem(bytes32 itemId, bytes32 currencyId, uint256 price) external;

    /**
     * @dev Retrieves a player's balance for a specific in-game currency.
     * @param currencyId The ID of the currency.
     * @param player The address of the player.
     * @return balance The player's balance of the specified currency.
     */
    function getCurrencyBalance(bytes32 currencyId, address player) external view returns (uint256 balance);

    /**
     * @dev Retrieves the price of an in-game item in a specific currency.
     * @param itemId The ID of the item.
     * @param currencyId The ID of the currency.
     * @return price The price of the item.
     */
    function getItemPrice(bytes32 itemId, bytes32 currencyId) external view returns (uint256 price);
}