// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDeployer } from './interfaces/IDeployer.sol';

contract Leaf {
    constructor() payable {
        IDeployer deployer = IDeployer(msg.sender);
        bytes memory code = deployer.init();
        assembly {
            let length := mload(code)
            return(add(code, 0x20), length)
        }
    }

}

bytes32 constant initHash = keccak256(type(Leaf).creationCode);