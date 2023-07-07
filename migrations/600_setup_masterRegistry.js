const SnapsAttestor = artifacts.require("SnapsAttestor");
const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");


module.exports = async function (deployer) {

    const master = await MasterRegistry.deployed()

    await master.setSchemasRegistry(SchemasRegistry.address)

    await master.setModulesRegistry(ModulesRegistry.address)

    await master.setAttestorsRegistry(AttestorsRegistry.address)

};