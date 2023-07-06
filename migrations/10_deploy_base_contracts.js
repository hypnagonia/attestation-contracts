const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

module.exports = async function (deployer) {
    await deployer.deploy(MasterRegistry)
    await deployer.deploy(SchemasRegistry)
    await deployer.deploy(AttestorsRegistry, SchemasRegistry.address)
    await deployer.deploy(ModulesRegistry)
};