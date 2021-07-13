var EmployeeContract = artifacts.require('./EmployeeContract.sol');

module.exports = function(deployer) {
  deployer.deploy(EmployeeContract, [
    "0x29B22d9cC45f3eCEc91515024988AeAE019C8B9F",
    "0x99e503a9c0B209846Fc7bcD337a8BF698e9A1fEf",
    "0x6C12FE2C6D04dD1Cd7D36A393E8b0f4D9a491f9d",
    "0x3b3741Ad9C39e6FCD0199097567Ce6D69a3a0D49"
    ], [
      "Bro Set",
      "Nao",
      "Seren",
      "Sumi"
    ], [
      5192389813200000,
      3123123811200000,
      2981923192900000,
      1991293999900000
    ]);
}
