// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;

import "./Debug.sol";

import "hardhat/console.sol";

import {DebugPrintContract} from "./Debug.sol";


contract DepositContract is DebugPrintContract {

    address private owner;

    mapping (address => uint) private balances;
    mapping (address => uint) private depositsDates;

    // Тип генерируемого события.
    event Withdrawal (uint amount, uint when);
    
    constructor () payable {

        owner = msg.sender;

    }

    function GetContractName () internal override pure returns (string memory) {
        return "DepositContract";
    }

    modifier OnlyOwner () {
        require(msg.sender == owner, "OnlyOwner");
        _;
    }

    // Запрос баланса адреса на контракте.
    function balanceOf (address addr) public view returns (uint){
        return balances[addr];
    }

    function deposit () public payable {

        // пополнить можно только пустой счёт
        require (balances[msg.sender] == 0, "Second deposit");
        
        balances[msg.sender] = msg.value;
        depositsDates[msg.sender] = block.timestamp;

        DebugPrint ("deposit ", msg.sender, msg.value);
    }

    // Высчитываем выплачиваемый процент.
    function CalculateInterest (uint amount) private pure returns (uint) {
        return (amount * 10) / 100;
    }

    // Запрос денег с депозита (возможно, с процентами).
    function withdraw (uint amount) public {

        require (amount > 0, "amount is null");
        require (balances[msg.sender] >= amount, "amount too big");
        balances[msg.sender] -= amount;

        uint amountForTranser = amount;

        // Если со времени размещения депозита прошло достаточно времени,
        // выплачиваем проценты.
        if (block.timestamp - depositsDates[msg.sender] > 60 seconds) {
            amountForTranser += CalculateInterest (amount);
        }

        if (amountForTranser > address(this).balance) {
            amountForTranser = address(this).balance;
        }

        // По умолчанию msg.sender имеет тип address.
        // Для перевода денег нужен тип address payable.
        payable(msg.sender).transfer (amountForTranser);

        // Генерируем событие.
        emit Withdrawal (amount, block.timestamp);

        DebugPrint ("withdraw ", msg.sender, amount);
    }

    // Владелец может уничтожить контракт и забрать все деньги.
    function destroy () public OnlyOwner {
        
        payable(owner).transfer (address(this).balance);

        // Начиная с cancun, контракт не будет удаляться.
        selfdestruct (payable(owner));
    }

}
