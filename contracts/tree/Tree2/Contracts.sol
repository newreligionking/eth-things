// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Leaf {
    constructor() {
        address target = Deployer(msg.sender).target();
        assembly {
            extcodecopy(target, 0, 0, extcodesize(target))
            return(0, extcodesize(target))
        }
    }
}

abstract contract Deployer {
    function _authorizeDeployment() internal virtual;

    function deploy(bytes4 selector, bytes calldata creationCode) external payable returns (address created) {
        _authorizeDeployment();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, creationCode.offset, creationCode.length)
            created := create(0, ptr, creationCode.length)
            mstore(0x40, add(ptr, creationCode.length))
            if iszero(created) { invalid() }
        }
        _storeTarget(created);
        created = address(new Leaf{salt: bytes32(selector)}());
        assembly {
            if iszero(created) { invalid() }
        }
    }

    function target() external view returns (address _target) {
        _target = _readTarget();
    }

    bytes32 constant private TARGET_SLOT = keccak256("TARGET_ADDRESS_STORAGE");

    function _storeTarget(address _target) private {
        bytes32 targetSlot = TARGET_SLOT;

        assembly {
            sstore(targetSlot, _target)
        }
    }

    function _readTarget() private view returns (address _target) {
        bytes32 targetSlot = TARGET_SLOT;

        assembly {
            _target := sload(targetSlot)
        }
    }
}

contract Tree {
    address immutable DEPLOYER;
    constructor(address deployer) { DEPLOYER = deployer; }

    fallback(bytes calldata) external payable returns (bytes memory) {
        address target = computeAddress(bytes32(msg.sig), keccak256(type(Leaf).creationCode), DEPLOYER);
        bytes memory input = msg.data[0 : msg.data.length];
        (bool success, bytes memory output) = target.delegatecall(input);
        require(success, string(output));
        return output;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}

contract ExampleDeployer is Deployer {
    mapping(address => bool) isAdmin;
    constructor(address[] memory admins) {
        for (uint256 i = 0; i < admins.length; i ++) {
            isAdmin[admins[i]] = true;
        }
    }
    function _authorizeDeployment() internal view override {
        require(isAdmin[msg.sender], "Not admin");
    }
}

contract Multiplier {
    uint256 immutable p;

    constructor(uint256 _p) {
        p = _p;
    }

    function multiply(uint256 x, uint256 y) external view returns (uint256 z) {
        if (p != 0) return x * p;
        else return x * y;
    }
}

contract Bootstrapper {
    constructor() {
        bytes4 selector = 0x165c4a16;
        uint256 x = 10;
        uint256 y = 22;
        uint256 p = 3;
        address[] memory admins = new address[](2);
        admins[0] = msg.sender;
        admins[1] = address(this);
        Deployer deployer = new ExampleDeployer(admins);
        deployer.deploy(selector, bytes.concat(type(Multiplier).creationCode, bytes32(p)));
        Tree tree = new Tree(address(deployer));
        (bool success, bytes memory output) = address(tree).delegatecall(abi.encodeWithSelector(selector, x, y));
        require(success, string(output));
        if (p == 0) {
            require(uint256(bytes32(output)) == x + y, "Doesn't add up");
        } else {
            require(uint256(bytes32(output)) == x * p, "Doesnt add up");
        }
    }
}