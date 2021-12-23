// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenInGame is Ownable {
    mapping(address => mapping(address => uint256)) public inGameBalance;
    mapping(address => uint256) public uniqueInGameTokens;
    mapping(address => address) public tokenPriceFeedMapping;

    address[] public allowedTokens;
    address[] public inGame;

    IERC20 public tavaresToken;

    constructor(address _tavaresTokenAddress) public {
        tavaresToken = IERC20(_tavaresTokenAddress);
    }

    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function inGameRewardTokens() public onlyOwner {
        for (
            uint256 inGameIndex = 0;
            inGameIndex < inGame.length;
            inGameIndex++
        ) {
            address recipient = inGame[inGameIndex];
            // send a token reward, based on total value in game
            uint256 userTotalValue = getUserTotalValue(recipient);
            tavaresToken.transfer(recipient, userTotalValue);
        }
    }

    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueInGameTokens[_user] > 0, "0 tokens in game");
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            totalValue =
                totalValue +
                getUserSingleTokenValue(
                    _user,
                    allowedTokens[allowedTokensIndex]
                );
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, address _token)
        public
        view
        returns (uint256)
    {
        if (uniqueInGameTokens[_user] <= 0) {
            return 0;
        }
        // price of the token * inGameBalance of the user
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        return ((inGameBalance[_token][_user] * price) / (10**decimals));
    }

    function getTokenValue(address _token)
        public
        view
        returns (uint256, uint256)
    {
        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    function inGameTokens(uint256 _amount, address _token) public {
        require(_amount > 0, "Amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        inGameBalance[_token][msg.sender] =
            inGameBalance[_token][msg.sender] +
            _amount;
        updateUniqueInGameTokens(msg.sender, _token);
        if (uniqueInGameTokens[msg.sender] == 1) {
            inGame.push(msg.sender);
        }
    }

    function updateUniqueInGameTokens(address _user, address _token) internal {
        if (inGameBalance[_token][_user] <= 0) {
            uniqueInGameTokens[_user] = uniqueInGameTokens[_user] + 1;
        }
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function SendTokensToWallet(address _token) public {
        uint256 balance = inGameBalance[_token][msg.sender];
        require(balance > 0, "In game balance cannot be 0");
        IERC20(_token).transfer(msg.sender, balance);
        inGameBalance[_token][msg.sender] = 0;
        uniqueInGameTokens[msg.sender] = uniqueInGameTokens[msg.sender] - 1;
    }
}
