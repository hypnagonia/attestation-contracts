const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaDIDVerificationModule = artifacts.require("KarmaDIDVerificationModule")
const SnapsRegistry = artifacts.require("SnapsRegistry")
const KeyValueParser = artifacts.require("libs/KeyValueParser");

module.exports = async function (deployer) {
    await deployer.deploy(KeyValueParser)
    await deployer.link(KeyValueParser, KarmaSnapsRegistryModule)
    await deployer.link(KeyValueParser, KarmaDIDVerificationModule)

    await deployer.deploy(
        KarmaSnapsRegistryModule,
        MasterRegistry.address,
        SchemasRegistry.address,
        AttestorsRegistry.address,
        SnapsRegistry.address
    )

    await deployer.deploy(
        KarmaDIDVerificationModule,
        MasterRegistry.address,
        SchemasRegistry.address,
        AttestorsRegistry.address,
    )

    const m = await ModulesRegistry.deployed()
    await m.registerModule(KarmaSnapsRegistryModule.address)
    await m.registerModule(KarmaDIDVerificationModule.address)

};