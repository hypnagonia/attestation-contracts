// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/Module.sol";

contract SnapsModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {}

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) external pure override returns (Attestation memory, bytes memory) {
        // implement logic here
        Attestation memory a = attestation;
        return (a, bytes(""));
    }
}
