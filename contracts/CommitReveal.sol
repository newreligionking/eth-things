// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

abstract contract CommitReveal {
    mapping(bytes32 => mapping(bytes32 => uint256)) commitments;
    mapping(bytes32 => bytes32) submissions;

    function _id(bytes32 ah, address account) private pure returns (bytes32 id) {
        id = keccak256(abi.encodePacked(ah, account));
    }

    function _commit(bytes32 q, bytes32 ah, address account) internal {
        uint256 time = block.timestamp;
        bytes32 id = _id(ah, account);
        require(commitments[q][id] == 0, "Exists");
        commitments[q][id] = time;
    }

    function _reveal(bytes32 q, bytes32 a, bytes32 r, address account) internal {
        bytes32 answer = keccak256(abi.encodePacked(a));
        _check(answer, q, a, r, account);
        bytes32 ah = keccak256(abi.encodePacked(a, r));
        bytes32 id = _id(ah, account);
        uint256 time = commitments[q][id];
        bytes32 best = submissions[q];
        if (best != 0) {
            require(commitments[q][best] > time, "Already submitted");
        }
        submissions[q] = id;
    }

    function _since(bytes32 q) internal view returns (uint256 since) {
        since = commitments[q][submissions[q]];
    }

    function _check(bytes32 answer, bytes32 q, bytes32, bytes32, address) internal virtual {
        require(answer == q, "Invalid answer");
    }
}