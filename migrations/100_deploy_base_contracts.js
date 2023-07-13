const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

const { schemas } = require('../src/schemas')

module.exports = async function (deployer) {
    await deployer.deploy(SchemasRegistry)
    
    await Promise.all(
        [
            deployer.deploy(MasterRegistry),
            deployer.deploy(AttestorsRegistry, SchemasRegistry.address),
            deployer.deploy(ModulesRegistry)
        ]
    )
};