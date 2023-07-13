const KeyValueParser = artifacts.require("libs/KeyValueParser");


module.exports = async function (deployer, network, accounts) {
    // await deployer.deploy(KeyValueParser)
    const c = await KeyValueParser.deployed()

    const res = await c.parseKeyValue(["name", "age"], ["me", "30"])
    const res2 = await c.getValueByKey("age")
    const res3 = await c.getValueByKey("name")
    
    // console.log(res2, res3)
}