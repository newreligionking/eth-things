// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Divider {
    function div(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x / y;
    }
}
contract Multiplier {
    function mul(uint256 x, uint256 y) external pure returns (uint256 z) {
        return x * y;
    }
}
interface IDeployer {
    function implementation() external view returns (address _implementation);
    struct DeployParams {
        bytes4 selector;
        address implementation;
    }
    function deploy(DeployParams calldata params) external payable returns (address created);
}
contract Leaf {
    /**
        6020 0x20
        3d 0 0x20
        3d 0 0 0x20
        3d 0 0 0 0x20
        33 caller 0 0 0 0x20
        5a gas caller 0 0 0 0x20
        fa success
        60jj jj success
        57
        3d 0
        51 impl
        80 impl impl
        15 iz_impl impl
        60jj jj iz_impl impl
        57 impl
        80 impl impl
        3b csize impl
        3d 0 csize impl
        81 csize 0 csize impl
        3d 0 csize 0 csize impl
        3d 0 0 csize 0 csize impl
        85 impl 0 0 csize 0 csize impl
        3c 0 csize impl
        f3
        5b
        fe
     */
    constructor() payable {
        IDeployer deployer = IDeployer(msg.sender);
        address implementation = deployer.implementation();
        assembly {
            let size := extcodesize(implementation)
            extcodecopy(implementation, 0, 0, size)
            return(0, size)
        }
    }
}
abstract contract BasicDeployer is IDeployer {
    address _implementation;
    function deploy(DeployParams calldata params) external payable returns (address created) {
        _authorize();
        _implementation = params.implementation;
        bytes32 salt = bytes32(params.selector);
        created = address(new Leaf{salt: salt, value: msg.value}());
        if (created == address(0)) revert();
    }
    function _authorize() internal virtual;
    function implementation() external view returns (address) {
        return _implementation;
    }
}
contract Tree {
    bytes32 constant leafCodeHash = keccak256(type(Leaf).creationCode);
    address immutable deployer;
    constructor(address d) { deployer = d; }
    fallback(bytes calldata) external payable returns (bytes memory) {
        bytes4 selector = msg.sig;
        address target = c2a(bytes32(selector), leafCodeHash, deployer);
        (bool success, bytes memory output) = target.delegatecall(msg.data);
        if (success) return output;
        revert(string(output));
    }
}
function c2a(bytes32 salt, bytes32 initCodeHash, address creator) pure returns (address account) {
    /// @solidity memory-safe-assembly
    assembly {
        let ptr := mload(0x40) // Get free memory pointer
        mstore(add(ptr, 0x40), initCodeHash)
        mstore(add(ptr, 0x20), salt)
        mstore(ptr, creator) // Right-aligned with 12 preceding garbage bytes
        let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
        mstore8(start, 0xff)
        account := keccak256(start, 85)
    }
}