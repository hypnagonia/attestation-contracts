const SnapsAttestor = artifacts.require("SnapsAttestor");
const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const storage = require('../src/utils/storage')
const { schemas } = require('../src/schemas')

module.exports = async function (deployer, network, accounts) {
    console.log('register schemas')

    const schema = schemas.snapAttestationSchema(AttestorsRegistry.address, accounts[0])

    const s = await SchemasRegistry.deployed()

    await s.setAttestorsRegistry(AttestorsRegistry.address)
    console.log('SchemasRegistry setAttestorsRegistry ok')

    const res = await s.registerSchema(SnapsAttestor.address, 'new no string', true)

    // console.log(JSON.stringify(res.logs))
    const schemaId = res.logs[0].args[0][0]
    console.log({ schemaId })

    console.log('SchemasRegistry registerSchema ok')


    // deploy test attestation
    const a = await SnapsAttestor.deployed()

    const attestationData = web3.utils.asciiToHex("")
    // const sa = await SnapsAttestor.deployed()

    const struct = {
        schemaId: schemaId,
        parentId: '0x0000000000000000000000000000000000000000000000000000000000000000',
        attestor: SnapsAttestor.address,
        attestee: accounts[0],
        expirationDate: 0,
        attestationData: attestationData
    }

    const res2 = await a.attest(struct, [attestationData])

    console.log(JSON.stringify(res2, null, 2))

};
