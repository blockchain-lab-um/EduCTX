var Migrations = artifacts.require("./Migrations.sol");

var DependencyManager = artifacts.require("./upgradeable/DependencyManager")
var CommunicationManager = artifacts.require("./upgradeable/CommunicationManager");
var EduCTXca = artifacts.require("./ca/EduCTXca");
var EduCTXcaData = artifacts.require("./ca/EduCTXcaData");
var RegisteredUser = artifacts.require("./users/RegisteredUser");
var RegisteredUserData = artifacts.require("./users/RegisteredUserData");
var EduCTXtoken = artifacts.require("./token/EduCTXtoken");
var EduCTXtokenData = artifacts.require("./token/EduCTXtokenData");


module.exports = async function (deployer) {
  // init migrations
  await deployer.deploy(Migrations);

  // upgradeability
  await deployer.deploy(DependencyManager);
  await deployer.deploy(CommunicationManager, DependencyManager.address);

  // ca
  await deployer.deploy(EduCTXca, DependencyManager.address);
  await deployer.deploy(EduCTXcaData, DependencyManager.address);

  // users
  await deployer.deploy(RegisteredUser, DependencyManager.address);
  await deployer.deploy(RegisteredUserData, DependencyManager.address);

  // token
  await deployer.deploy(EduCTXtoken, DependencyManager.address);
  await deployer.deploy(EduCTXtokenData, DependencyManager.address);

};


// module.exports = function (deployer) {
//   deployer.deploy(Migrations);
// };
