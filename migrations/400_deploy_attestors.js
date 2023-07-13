const SnapsAttestor = artifacts.require("SnapsAttestor");
const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")
const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaDIDVerificationModule = artifacts.require("KarmaDIDVerificationModule")

module.exports = async function (deployer) {
    await deployer.deploy(
        KarmaAttestorV1,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        // validation modules
        [
            KarmaSnapsRegistryModule.address,
            KarmaDIDVerificationModule.address
        ]
    );

    const attestorsRegistry = await AttestorsRegistry.deployed()
    await attestorsRegistry.registerAttestor(KarmaAttestorV1.address)
};