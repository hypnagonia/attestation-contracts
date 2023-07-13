const SnapsRegistry = artifacts.require("./metamask/SnapsRegistry");
const EthereumDIDRegistry = artifacts.require("./did/EthereumDIDRegistry");


module.exports = async function (deployer, network, accounts) {

    await deployer.deploy(SnapsRegistry, "snapsRegistryMock", "snaps")
    await deployer.deploy(EthereumDIDRegistry)

    const s = await SnapsRegistry.deployed()
    const res = await s.addSnap("testSnap", "description", "Jenya", 0, "")
    const snapId = res.logs[0].args[0].toString()
    // console.log({ snapId })
    const res2 = await s.addSnapVersion(snapId, "shasum", "location", "1.1", "changelog")

    //  await s.addSnapVersion(snapId, "shasum2", "location2", "2", "new stuff")

    // console.log(res2.logs[0].args)

    // const res3 = await s.getSnap(snapId)
    // const res3 = await s.getSnapVersions(snapId)
    // const res3 = await s.getSnapVersion("shasum2")

    // console.log(res3)
};
