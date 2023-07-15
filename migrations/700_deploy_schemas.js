const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")
const ethers = require('ethers')
// const storage = require('../src/utils/storage')
// const { schemas } = require('../src/schemas')

const KarmaAuditAttestor = artifacts.require("KarmaAuditAttestor")
const KarmaAuditApprovalAttestor = artifacts.require("KarmaAuditApprovalAttestor")
const KarmaReviewApprovalAttestor = artifacts.require("KarmaReviewApprovalAttestor")
const KarmaReviewAttestor = artifacts.require("KarmaReviewAttestor")


module.exports = async function (deployer, network, accounts) {
    console.log('register schemas')

    // const schema = schemas.snapAttestationSchema(AttestorsRegistry.address, accounts[0])

    const sc = await SchemasRegistry.deployed()

    await sc.setAttestorsRegistry(AttestorsRegistry.address)
    console.log('SchemasRegistry setAttestorsRegistry ok')

    const KarmaAuditAttestorSchema = ["snapChecksum", "attestationReport", "isTrustworthy"]
        .map(e => ethers.hexlify(ethers.toUtf8Bytes(e)))

    console.log(KarmaAuditAttestorSchema)
    const res = await sc.registerSchema(KarmaAuditAttestor.address, KarmaAuditAttestorSchema, true, "KarmaAuditAttestorSchema")
    const KarmaAuditAttestorSchemaSchemaId = res.logs[0].args[0][0]

    const KarmaAuditApprovalAttestorSchema = ["attestationId", "isApproved"]
        .map(e => ethers.hexlify(ethers.toUtf8Bytes(e)))

    const res2 = await sc.registerSchema(KarmaAuditApprovalAttestor.address, KarmaAuditApprovalAttestorSchema, true, "KarmaAuditApprovalAttestorSchema")
    const KarmaAuditApprovalAttestorSchemaId = res2.logs[0].args[0][0]

    const KarmaReviewApprovalAttestorSchema = ["attestationId", "isApproved"]
        .map(e => ethers.hexlify(ethers.toUtf8Bytes(e)))

    const res3 = await sc.registerSchema(KarmaReviewApprovalAttestor.address, KarmaReviewApprovalAttestorSchema, true, "KarmaReviewApprovalAttestorSchema")
    const KarmaReviewApprovalAttestorSchemaId = res3.logs[0].args[0][0]

    const KarmaReviewAttestorSchema = ["snapChecksum", "attestationReport", "score"]
        .map(e => ethers.hexlify(ethers.toUtf8Bytes(e)))

    const res4 = await sc.registerSchema(KarmaReviewAttestor.address, KarmaReviewAttestorSchema, true, "KarmaReviewAttestorSchema")
    const KarmaReviewAttestorSchemaId = res4.logs[0].args[0][0]


    console.log({ KarmaAuditApprovalAttestorSchemaId, KarmaReviewAttestorSchemaId, KarmaAuditAttestorSchemaSchemaId, KarmaReviewApprovalAttestorSchemaId })
    console.log('SchemasRegistry registerSchema ok')

    // deploy test attestation
    const a = await KarmaAuditAttestor.deployed()

    const extraData = web3.utils.asciiToHex("")

    // check schemaFields
    const attestationData = ["shasum", "", ""]
        .map(e => ethers.hexlify(ethers.toUtf8Bytes(e)))
    // const sa = await SnapsAttestor.deployed()

    const attestation = {
        schemaId: KarmaAuditAttestorSchemaSchemaId,
        parentId: '0x0000000000000000000000000000000000000000000000000000000000000000',
        attestor: KarmaAuditAttestor.address,
        attestee: accounts[0],
        expirationDate: 0,
        attestationData
    }

    try {
        // second arg array for each module accordingly 
        const attestationResult = await a.attest(attestation, [extraData, extraData])

        console.log(JSON.stringify(attestationResult, null, 2))
    } catch (e) {
        console.log(e)
    }
};
