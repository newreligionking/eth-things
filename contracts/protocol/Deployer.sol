// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDeployer } from './interfaces/IDeployer.sol';
import { Leaf } from "./Leaf.sol";

contract Deployer is IDeployer {
    address immutable owner;

    bytes _code;

    constructor(address _owner) { owner = _owner; }

    function deploy(bytes4 selector, bytes calldata code) external payable returns (address created) {
        require(msg.sender == owner, "Not Owner");
        _code = code;
        created = address(new Leaf{value: msg.value, salt: bytes32(selector)}());
        if (created == address(0)) revert("Missed deployment");
    }

    function init() external view returns (bytes memory code) {
        return _code;
    }
}