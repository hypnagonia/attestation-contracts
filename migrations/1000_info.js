const SnapsModule = artifacts.require("SnapsModule");
const SnapsAttestor = artifacts.require("SnapsAttestor");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");


module.exports = async function (deployer) {

    const modules = [SnapsAttestor, SnapsModule, MasterRegistry, ModulesRegistry, SchemasRegistry, AttestorsRegistry]

    console.table(modules.map(m => ({ name: m._json.contractName, address: m.address })))


    console.log('Registered Modules')

    const modulesRegistry = await ModulesRegistry.deployed()
    const isSnapModuleRegistered = await modulesRegistry.isRegistered(SnapsModule.address)

    const attestorsRegistry = await AttestorsRegistry.deployed()
    const isSnapsAttestorRegistered = await attestorsRegistry.isRegistered(SnapsAttestor.address)

    console.log({ isSnapModuleRegistered, isSnapsAttestorRegistered })
}