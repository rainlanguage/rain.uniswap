// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.18;

/// @title FixedPoint968x
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol
library FixedPoint968x {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}
