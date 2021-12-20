// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    event Bought(uint256 amount);
    event Sold(uint256 amount);

    IERC20 public w6gToken;

    function buy() public payable {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = w6gToken.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some BNB");
        require(
            amountTobuy <= dexBalance,
            "Not enough w6gTokens in the reserve"
        );
        w6gToken.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public payable {
        require(amount > 0, "You need to sell at least some w6gTokens");
        uint256 allowance = w6gToken.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the w6gToken allowance");
        w6gToken.transferFrom(msg.sender, payable(address(this)), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
}
