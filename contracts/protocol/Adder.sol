// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Adder {
    function add(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x + y;
    }
}