// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../base/Module.sol";
import {Schema} from "../../libs/Structs.sol";


contract KarmaDIDVerificationModule is Module {
    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {

    }

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) external override returns (Attestation memory, bytes memory) {
        
        // did
        
        return (attestation, bytes(""));
    }
}
