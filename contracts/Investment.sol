// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;

contract Investment {
    event CheckBalance(address indexed from, uint256 amount);
    // amount returned to user
    uint256 balanceAmount;
    // amount deposited by user
    uint256 depositAmount;
    // minimum amount to be deposited by user
    uint256 thresholdAmount;
    // amount to be returned in addition to depositAmount to user
    uint256 returnOnInvestment;

    constructor() public {
        balanceAmount = getBalanceAmount();
        depositAmount = 0;
        thresholdAmount = 12;
        returnOnInvestment = 3;

        emit CheckBalance(msg.sender, balanceAmount );
    }

    // read operation
    function getBalanceAmount() public view returns (uint256) {
        return msg.sender.balance/(1e16);
    }

    // read operation
    function getDepositAmount() public view returns (uint256) {
        return depositAmount;
    }

    // write operation
    function addDepositAmount(uint256 amount) public {
        depositAmount = depositAmount + amount;

        if (depositAmount >= thresholdAmount) {
            balanceAmount = depositAmount + returnOnInvestment;
        }
    }

    // write function
    function withdrawBalance() public {
        balanceAmount = 0;
        depositAmount = 0;
    }
}
