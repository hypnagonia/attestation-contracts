
const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
// const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")
const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaDIDVerificationModule = artifacts.require("KarmaDIDVerificationModule")


const KarmaAuditAttestor = artifacts.require("KarmaAuditAttestor")
const KarmaAuditApprovalAttestor = artifacts.require("KarmaAuditApprovalAttestor")
const KarmaReviewApprovalAttestor = artifacts.require("KarmaReviewApprovalAttestor")
const KarmaReviewAttestor = artifacts.require("KarmaReviewAttestor")


module.exports = async function (deployer) {
    /*
    await deployer.deploy(
        KarmaAttestorV1,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        [
            KarmaSnapsRegistryModule.address,
            KarmaDIDVerificationModule.address
        ]
    );*/

    await deployer.deploy(
        KarmaAuditAttestor,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        [
            KarmaSnapsRegistryModule.address,
            KarmaDIDVerificationModule.address
        ]
    )

    await deployer.deploy(
        KarmaReviewAttestor,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        [
            KarmaSnapsRegistryModule.address,
            KarmaDIDVerificationModule.address
        ]
    )

    await deployer.deploy(
        KarmaAuditApprovalAttestor,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        [
            KarmaDIDVerificationModule.address
        ]
    )

    await deployer.deploy(
        KarmaReviewApprovalAttestor,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        [
            KarmaDIDVerificationModule.address
        ]
    )

    const attestorsRegistry = await AttestorsRegistry.deployed()

    await attestorsRegistry.registerAttestor(KarmaAuditAttestor.address)
    await attestorsRegistry.registerAttestor(KarmaReviewAttestor.address)
    await attestorsRegistry.registerAttestor(KarmaReviewApprovalAttestor.address)
    await attestorsRegistry.registerAttestor(KarmaAuditApprovalAttestor.address)
};