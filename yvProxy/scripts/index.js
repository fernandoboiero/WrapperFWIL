module.exports = async function main(callback) {
    try {
        // const accounts = await web3.eth.getAccounts();
        // console.log(accounts);
        const Box = artifacts.require("Box");
        const box = await Box.deployed();

        await box.store(23);

        value = await box.retrieve();
        console.log("Box value is", value.toString());
        callback(0);
    } catch (error) {
        console.log(error);
        callback(1);
    }
};
