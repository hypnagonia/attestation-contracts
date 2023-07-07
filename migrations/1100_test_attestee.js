const SnapsModule = artifacts.require("SnapsModule");
const SnapsAttestor = artifacts.require("SnapsAttestor");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");
const { ethers } = require('ethers')
const web3 = require('web3')

module.exports = async function (deployer, network, accounts) {


    const a = await SnapsAttestor.deployed()

    /*
    struct AttestationRequest {
    bytes32 schemaId; // The unique identifier of the schema used.
    bytes32 parentId; // The unique identifier of the parent attestation (see DAG).
    address attestor; // The Attestor smart contract address.
    address attestee; // The Attestee address (receiving attestation).
    uint64 expirationDate; // The expiration date of the attestation.
    bytes attestationData; // The attestation data.
}
    */

    try {
        // const extraData = ethers.arrayify("extra data")

        const parentId = web3.utils.asciiToHex("")
        const attestationData = web3.utils.asciiToHex("")
        // const sa = await SnapsAttestor.deployed()

        const struct = {
            schemaId: "0x09b437fcbefe2989cbb59b63ca04aa8a6821dc87cf39ab83e9fcf37aa82eb7c5",
            parentId: '0x0000000000000000000000000000000000000000000000000000000000000000',
            attestor: SnapsAttestor.address,
            attestee: accounts[0],
            expirationDate: 0,
            attestationData: attestationData
        }

        const res = await a.attest(struct, [attestationData])
        
        console.log(JSON.stringify(res, null, 2))

    } catch (e) {
        console.log(JSON.stringify(e, null, 2))
        throw e
    }

}
// 0x44bf34e1425a6ea7ce9bf82f8f6556394f39192bfde6e07452bce02a6a3f87ae