const RewardToken = artifacts.require("RewardToken");
const Staker = artifacts.require("Staker");

module.exports = async (deployer) => {
  await deployer.deploy(RewardToken, "RewardToken", "RWT");
  const rewardToken = await RewardToken.deployed();

  await deployer.deploy(Staker, rewardToken.address, 100000);
};
