pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract W6GToken is ERC20 {
    constructor() public ERC20("W6G Token v2", "TVC") {
        // initial supply 1 million
        _mint(msg.sender, 1000000000000000000000000);
    }
}
