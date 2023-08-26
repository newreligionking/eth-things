// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDeployer {
    function deploy(bytes4 selector, bytes calldata runtimeCode) external payable returns (address created);
    function init() external returns (bytes memory code);
}