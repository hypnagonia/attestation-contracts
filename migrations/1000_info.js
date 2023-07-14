const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const { schemas } = require('../src/schemas')
const parseLogs = require('../src/utils/parseLogs')
const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")

module.exports = async function (deployer) {
    const modules = [
        MasterRegistry, ModulesRegistry, SchemasRegistry, AttestorsRegistry,
        KarmaSnapsRegistryModule, KarmaAttestorV1
    ]

    console.table(modules.map(m => ({ name: m._json.contractName, address: m.address })))

    /*
    console.log('Registered Modules')

    const modulesRegistry = await ModulesRegistry.deployed()
    const isSnapModuleRegistered = await modulesRegistry.isRegistered(SnapsModule.address)

    const attestorsRegistry = await AttestorsRegistry.deployed()
    const isSnapsAttestorRegistered = await attestorsRegistry.isRegistered(SnapsAttestor.address)

    console.log({ isSnapModuleRegistered, isSnapsAttestorRegistered })
    */

}
