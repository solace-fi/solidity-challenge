pragma solidity 0.6.5;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./RewardToken.sol";

contract Staker is ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    address public owner;

    address[] public stakerAddresses;
    mapping(address => bool) public stakers;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public rewards;
    uint256 public stakerCount;
    uint256 internal stakerAddressIndexCounter;

    // stake reward token address
    RewardToken rewardToken;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner of the contract can run this operation"
        );
        _;
    }

    event Deposit(address indexed staker, uint256 amount);
    event WithDraw(address indexed staker, uint256 amount);

    constructor(RewardToken _rewardToken, uint256 _tokenAmount) public {
        owner = msg.sender;
        rewardToken = _rewardToken;
        rewardToken.mint(msg.sender, _tokenAmount);
    }

    function isStaker(address _address) public view returns (bool) {
        return stakers[_address];
    }

    function getStakerAddressIndex(address _address)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < stakerAddresses.length; i += 1) {
            if (_address == stakerAddresses[i]) return i;
        }
    }

    function addStaker(address _address) public returns (bool) {
        if (!isStaker(_address)) {
            stakerAddresses.push(_address);
            stakers[_address] = true;
            stakerCount++;
        }
        return stakers[_address];
    }

    function removeStaker(address _address) public returns (bool) {
        if (isStaker(_address)) {
            stakers[_address] = false;
            uint256 stakerIndex = getStakerAddressIndex(_address);
            stakerAddresses[stakerIndex] = stakerAddresses[stakerCount - 1];
            stakerAddresses.pop();
            stakerCount--;
            return true;
        }
        return false;
    }

    function stakeAmount(address _staker) public view returns (uint256) {
        if (isStaker(_staker)) {
            return stakes[_staker];
        }
        return 0;
    }

    function totalStakeAmount() public view returns (uint256) {
        uint256 stakeAmountSum = 0;
        for (uint256 i = 0; i < stakerCount; i++) {
            stakeAmountSum = stakeAmountSum.add(
                stakeAmount(stakerAddresses[i])
            );
        }
        return stakeAmountSum;
    }

    function deposit(uint256 _stakeAmount) public {
        rewardToken.burn(msg.sender, _stakeAmount);

        if (!isStaker((msg.sender))) {
            addStaker(msg.sender);
        }

        stakes[msg.sender] = stakes[msg.sender].add(_stakeAmount);
        emit Deposit(msg.sender, _stakeAmount);
    }

    function withDraw() public {
        uint256 amount = stakes[msg.sender] + rewards[msg.sender];
        removeStaker(msg.sender);
        rewardToken.mint(msg.sender, amount);
        emit WithDraw(msg.sender, amount);
    }

    function distributeRewards() public onlyOwner {
        for (uint256 i = 0; i < stakerCount; i++) {
            address staker = stakerAddresses[i];
            uint256 earnedReward = stakes[staker].div(100);
            rewards[staker] = rewards[staker].add(earnedReward);
        }
    }
}
