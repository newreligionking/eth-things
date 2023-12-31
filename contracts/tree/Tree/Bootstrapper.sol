// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDeployer } from './interfaces/IDeployer.sol';
import { Deployer } from './Deployer.sol';
import { Adder } from './Adder.sol';
import { Tree } from './Tree.sol';
contract Bootstrapper {
    constructor(bytes4 selector, uint256 x, uint256 y) {
        IDeployer deployer = new Deployer(msg.sender);
        deployer.deploy(selector, type(Adder).runtimeCode);
        Tree tree = new Tree(address(deployer));
        (bool success, bytes memory output) = address(tree).delegatecall(abi.encodeWithSelector(selector, x, y));
        require(success, string(output));
        require(uint256(bytes32(output)) == x + y, "Doesn't add up");
    }
}