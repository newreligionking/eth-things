// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import { CommitReveal } from "./CommitReveal.sol";

contract Timelocked is CommitReveal {
    bytes32 constant q = 0;
    uint256 constant step = 1;
    uint256 constant freq = 5 days;
    uint256 immutable start;

    constructor() payable {
        start = block.timestamp;
    }

    receive() external payable {}
    
    fallback() external payable {}
    
    function submit(bytes32 ah) external {
        _commit(q, ah, msg.sender);
    }

    function claim(bytes32 a, bytes32 r) external {
        _reveal(q, a, r, msg.sender);
    }

    function _check(bytes32 answer, bytes32 _q, bytes32, bytes32, address) internal override view {
        if (answer == _q) return;
        uint256 bits = (block.timestamp - start) / freq * step;
        if (answer >> bits != _q >> bits) revert("No match");
    }

    function withdraw() external {
        uint256 since = _since(q);
        require(block.timestamp - since > 1 days, "Wait");
        payable(msg.sender).transfer(address(this).balance);
    }

}