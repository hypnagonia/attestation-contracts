const contract = require("truffle-contract");
const web3 = require('web3')

module.exports = async function (contract, result) {

    // Parse logs
    const logs = result.receipt ? result.receipt.logs : result


    logs.forEach((log) => {
        const EventABI = contract.abi.find((item) => item.name === log.event);

        const decodedLog = web3.eth.abi.decodeLog(EventABI.inputs, log.data, log.topics.slice(1));
        console.log(decodedLog);


    });
};