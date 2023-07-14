const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

const KarmaSnapsRegistryModule = artifacts.require("KarmaSnapsRegistryModule")
const KarmaAttestorV1 = artifacts.require("KarmaAttestorV1")
const ethers = require('ethers')
const storage = require('../src/utils/storage')
const { schemas } = require('../src/schemas')

module.exports = async function (deployer, network, accounts) {
    console.log('register schemas')

    // const schema = schemas.snapAttestationSchema(AttestorsRegistry.address, accounts[0])

    const sc = await SchemasRegistry.deployed()

    await sc.setAttestorsRegistry(AttestorsRegistry.address)
    console.log('SchemasRegistry setAttestorsRegistry ok')

    const schemaFields = ["snapChecksum"]
    const res = await sc.registerSchema(KarmaAttestorV1.address, schemaFields, true, "this is test schema")

    const schemaId = res.logs[0].args[0][0]
    console.log({ schemaId })

    console.log('SchemasRegistry registerSchema ok')

    // deploy test attestation
    const a = await KarmaAttestorV1.deployed()

    const extraData = web3.utils.asciiToHex("")

    // check schemaFields
    const attestationData = ["shasum"]
    // const sa = await SnapsAttestor.deployed()


    const signature = "0x698255411dc166881a2d9470c5f7d536204c7c4c9572202e439f8a7941485b62161c16a04bf42b6d23dff7b302a0ced4d27479fc18e7fc2ef61d58837fcc583a1b"

    const attestation = {
        schemaId: schemaId,
        parentId: '0x0000000000000000000000000000000000000000000000000000000000000000',
        attestor: KarmaAttestorV1.address,
        attestee: accounts[0],
        expirationDate: 0,
        attestationData
    }

    // second arg array for each module accordingly 

    try {
        const res2 = await a.attest(attestation, [extraData, extraData])

        console.log(JSON.stringify(res2, null, 2))
    } catch (e) {
        console.log(e)
    }
};
