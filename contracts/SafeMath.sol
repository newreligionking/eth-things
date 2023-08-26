// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

function add(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        assembly {
            z := add(x, y)
            if gt(x, z) { invalid() }
        }
    }
}

function sub(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        assembly {
            z := sub(x, y)
            if gt(z, x) { invalid() }
        }
    }
}

function mul(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        assembly {
            z := mul(x, y)
            if iszero(or(x, eq(div(z, x), y))) { invalid() }
        }
    }
}