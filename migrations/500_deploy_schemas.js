const SnapsAttestor = artifacts.require("SnapsAttestor");
const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");

const { schemas } = require('../src/schemas')

module.exports = async function (deployer, network, accounts) {
    console.log('register schemas')

    const schema = schemas.snapAttestationSchema(AttestorsRegistry.address, accounts[0])
    // const schemasRegistry = await SchemasRegistry.deployed()

    // const attestorsRegistry = await AttestorsRegistry.deployed()
    const s = await SchemasRegistry.deployed()

    await s.setAttestorsRegistry(AttestorsRegistry.address)
    console.log('SchemasRegistry setAttestorsRegistry ok')

    const res = await s.registerSchema(SnapsAttestor.address, 'new no string', true)

    console.log(JSON.stringify(res.logs))
    const schemaId = res.logs[0].args[0][0]
    console.log({ schemaId })
    console.log('SchemasRegistry registerSchema ok')

};
