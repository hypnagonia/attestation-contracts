const SnapsAttestor = artifacts.require("SnapsAttestor");
const SnapsModule = artifacts.require("SnapsModule");

const MasterRegistry = artifacts.require("MasterRegistry");
const ModulesRegistry = artifacts.require("ModulesRegistry");
const SchemasRegistry = artifacts.require("SchemasRegistry");
const AttestorsRegistry = artifacts.require("AttestorsRegistry");


module.exports = async function (deployer) {
    await deployer.deploy(
        SnapsAttestor,
        MasterRegistry.address,
        SchemasRegistry.address,
        ModulesRegistry.address,
        // modules to validate 
        [SnapsModule.address]
    );

    const attestorsRegistry = await AttestorsRegistry.deployed()
    await attestorsRegistry.registerAttestor(SnapsAttestor.address)
};