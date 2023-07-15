const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const { schemas } = require('../src/schemas')
const parseLogs = require('../src/utils/parseLogs')
const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
// const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")

const KarmaAuditAttestor = artifacts.require("KarmaAuditAttestor")
const KarmaAuditApprovalAttestor = artifacts.require("KarmaAuditApprovalAttestor")
const KarmaReviewApprovalAttestor = artifacts.require("KarmaReviewApprovalAttestor")
const KarmaReviewAttestor = artifacts.require("KarmaReviewAttestor")

module.exports = async function (deployer) {
    const modules = [
        MasterRegistry, ModulesRegistry, SchemasRegistry, AttestorsRegistry,
        KarmaSnapsRegistryModule,
        KarmaAuditAttestor,
        KarmaAuditApprovalAttestor,
        KarmaReviewApprovalAttestor,
        KarmaReviewAttestor,
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
