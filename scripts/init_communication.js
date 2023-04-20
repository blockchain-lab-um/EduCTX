var CommunicationManager = artifacts.require("./upgradeable/CommunicationManager");
var EduCTXtoken = artifacts.require("./EduCTXtoken");
var EduCTXtokenData = artifacts.require("./EduCTXtokenData");
var EduCTXca = artifacts.require("./ca/EduCTXca");
var EduCTXcaData = artifacts.require("./ca/EduCTXcaData");
var RegisteredUser = artifacts.require("./users/RegisteredUser");
var RegisteredUserData = artifacts.require("./users/RegisteredUserData");

var accountFrom = "0x82083053a1825780295af932F884d435b1bFb51a";


module.exports = async function () {

  await EduCTXca.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "EduCTXca init()", result.tx)
  })

  await EduCTXcaData.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "EduCTXcaData init()", result.tx)
  })

  await EduCTXtoken.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "EduCTXtoken init()", result.tx)
  })

  await EduCTXtokenData.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "EduCTXtokenData init()", result.tx)
  })

  await RegisteredUser.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "RegisteredUser init()", result.tx)
  })

  await RegisteredUserData.deployed().then(async (instance) => {
    let result = await instance.init({ from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "RegisteredUserData init()", result.tx)
  })

  await CommunicationManager.deployed().then(async (instance) => {
    let result;
    result = await instance.addCommunication("EduCTXtokenData", "EduCTXtoken", { from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "CommunicationManager addCommunication(EduCTXtokenData,EduCTXtoken)", result.tx)
    result = await instance.addCommunication("EduCTXcaData", "EduCTXca", { from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "CommunicationManager addCommunication(EduCTXcaData,EduCTXca)", result.tx)
    result = await instance.addCommunication("RegisteredUserData", "RegisteredUser", { from: accountFrom });
    console.log('Transakcija %s uspesna, txHash: %s', "CommunicationManager addCommunication(RegisteredUserData,RegisteredUser)", result.tx);
    process.exit();
  })

};
