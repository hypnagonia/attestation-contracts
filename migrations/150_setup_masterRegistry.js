const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

module.exports = async function (deployer) {
    const master = await MasterRegistry.deployed()
    await Promise.all(
        [
            master.setSchemasRegistry(SchemasRegistry.address),
            master.setModulesRegistry(ModulesRegistry.address),
            master.setAttestorsRegistry(AttestorsRegistry.address)
        ])
};