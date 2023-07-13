// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Schema} from "./libs/Structs.sol";
import {AttestorsRegistry} from "./AttestorsRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISchemasRegistry.sol";

// todo rights to create
contract SchemasRegistry is ISchemasRegistry, Ownable {
    AttestorsRegistry private $attestorsRegistry;

    mapping(bytes32 schemaId => Schema schema) private $schemas;

    uint256 public schemaCount;

    function setAttestorsRegistry(
        address _attestorsRegistry
    ) external onlyOwner {
        if (_attestorsRegistry == address(0))
            revert InvalidAttestorsRegistryAddress();
        $attestorsRegistry = AttestorsRegistry(_attestorsRegistry);

        emit AttestorsRegistrySet(_attestorsRegistry);
    }

    function registerSchema(
        address attestor,
        string[] memory schema,
        bool onChain,
        string memory description
    ) external {
        if (address($attestorsRegistry) == address(0))
            revert AttestorsRegistryNotSet();

        string memory schemas = "";
        for (uint i = 0; i < schema.length; i++) {
            // todo less memory
            schemas = string(abi.encodePacked(schemas, schema[i]));
        }

        Schema memory newSchema = Schema({
            schemaId: keccak256(abi.encodePacked(msg.sender, attestor, schemas)),
            schemaNumber: ++schemaCount,
            creator: msg.sender,
            attestor: attestor,
            isPrivate: false,
            onChainAttestation: onChain,
            schema: schema,
            description: description
        });

        if ($schemas[newSchema.schemaId].schemaId != bytes32(0))
            revert SchemaAlreadyExists();

        $schemas[newSchema.schemaId] = newSchema;

        $attestorsRegistry.registerSchema(newSchema);

        emit SchemaRegistered(newSchema);
    }

    function getSchema(bytes32 schemaId) external view returns (Schema memory) {
        return $schemas[schemaId];
    }

    function getAttestorsRegistry() public view returns (address) {
        return address($attestorsRegistry);
    }
}
