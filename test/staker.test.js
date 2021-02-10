let RewardToken = artifacts.require("RewardToken");
let Staker = artifacts.require("Staker");

let BN = web3.utils.BN;

contract("Staker", (accounts) => {
  let stakerContract;
  let rewardTokenContract;
  const tokenAmount = 1000;
  const owner = accounts[0];
  const user = accounts[1];

  describe("Staking", () => {
    beforeEach(async () => {
      rewardTokenContract = await RewardToken.new("RewardToken", "RWT");
      stakerContract = await Staker.new(
        rewardTokenContract.address,
        tokenAmount
      );
    });

    it("deposit(): creates a stake", async () => {
      await rewardTokenContract.transfer(user, 200, { from: owner });
      await stakerContract.deposit(100, { from: user });

      assert.equal(await rewardTokenContract.balanceOf(user), 100);
      assert.equal(await stakerContract.stakeAmount(user), 100);
      assert.equal(await stakerContract.totalStakeAmount(), 100);
    });
  });
});
