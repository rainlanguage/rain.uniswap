// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev Thrown when an undirected amount is zero.
error UniswapV2ZeroAmount();

/// @dev Thrown when an input amount is zero.
error UniswapV2ZeroInputAmount();

/// @dev Throw when an output amount is zero.
error UniswapV2ZeroOutputAmount();

/// @dev Thrown when a reserve is zero.
error UniswapV2ZeroLiquidity();

/// @dev Thrown when the two token addresses are identical.
error UniswapV2IdenticalAddresses();

/// @dev Thrown when some token address is the zero address.
error UniswapV2ZeroAddress();
