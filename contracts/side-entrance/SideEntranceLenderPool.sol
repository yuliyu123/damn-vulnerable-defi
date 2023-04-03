// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "hardhat/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    // 接收ether函数, deposit为payable，可接收{value: 1000 ether}, 同时balances[msg.sender] += 1000 ether
    function deposit() external payable {
        console.log("e2 msg.sender: ", msg.sender);
        console.log("e2 address : ", address(this));
        console.log("e2 address(this).balance: ", address(this).balance);
        unchecked {
            balances[msg.sender] += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
        delete balances[msg.sender];
        emit Withdraw(msg.sender, amount);

        SafeTransferLib.safeTransferETH(msg.sender, amount);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        console.log("before flash loan address(this).balance: ", address(this).balance);

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
        console.log("after flash loan address(this).balance: ", address(this).balance);
        if (address(this).balance < balanceBefore)
            revert RepayFailed();
    }
}
