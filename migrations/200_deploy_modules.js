const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

module.exports = async function (deployer) {
    await deployer.deploy(
        SnapsModule,
        MasterRegistry.address,
        SchemasRegistry.address,
        AttestorsRegistry.address
    )

    const m = await ModulesRegistry.deployed()
    await m.registerModule(SnapsModule.address)
};