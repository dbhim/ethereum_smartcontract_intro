// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;

import "./Debug.sol";

import "hardhat/console.sol";


contract HelloWorld is DebugPrintContract {

    uint startValue = 333330;

    address payable creator;

    //constructor (uint value) payable {
    constructor () payable {

        creator = payable(msg.sender);

        console.log ("gasleft() = %s\n", gasleft());

        PrintInfo();
    }

    function GetContractName () internal override pure returns (string memory) {
        return "Hello";
    }

    // Вызывается при вызове функции с пустым селектором (пустой calldata).
    receive() external payable {
        string memory msgStr = GetContractName();
        console.log ("[%s] receive value = %s, gasleft = %s\n", msgStr, msg.value, gasleft());
    }

    // Вызывается при вызове функции с несуществующим селектором.
    fallback() external payable {
        string memory msgStr = GetContractName();
        console.log ("[%s] fallback value = %s, gasleft = %s\n", msgStr, msg.value, gasleft());
    }

    function Hello (uint a) public payable {

        string memory msgStr = GetContractName();
        console.log ("[%s] Hello from %s. a = %s, ", msgStr, msg.sender, a);
        console.log ("value = %s", msg.value);
        console.log ("gasleft = %s\n", gasleft());

        // цикл для траты газа
        for (uint i = 0; i < 50; ++i) {
            uint a = i;
        }
        console.log ("gasleft = %s\n", gasleft());

        //PrintInfo();
    }

    function SelfDestroy () public {

        // Контракт удаляется (уже нет) и все деньги пересылаются на адрес из аргумента.
        selfdestruct (creator);
    }

    // Выводит значение из слота в storage.
    function ShowStorageValue () public view {

        DebugPrint ("ShowStorageValue: ", startValue);
    }

}



contract HelloWorld2 {

    uint startValue = 444440;

    receive() external payable {
        
        require (msg.value > 1 ether);

        // Через send/transfer передаётся так мало газа,
        // что не хватит даже на отладочный вывод.
        //console.log ("[Hello2] receive value = %s, gasleft = %s\n", msg.value, gasleft());
    }

    fallback() external payable {
        
        console.log ("[Hello2] fallback value = %s, gasleft = %s\n", msg.value, gasleft());
    }

    function Revert (uint a) public {

        ++startValue;
        
        console.log ("Revert: %s -> %s startValue = %s", msg.sender, address(this), startValue);
        if (a > 0)
            revert ("[Hello2] Revert");
    }
}


contract HelloWorld3 {

    receive() external payable {
        
        require (msg.value > 1 ether);

        console.log ("[Hello3] receive value = %s, gasleft = %s\n", msg.value, gasleft());
    }

    fallback() external payable {
        
        console.log ("[Hello3] fallback value = %s, gasleft = %s\n", msg.value, gasleft());
    }

    function NotPayableFunction() public view {

        uint value;
        assembly {
            value := callvalue()
        }

        console.log ("[Hello3] NotPayableFunction value = %s, gasleft = %s\n", value, gasleft());
    }

    function fun (uint a) external pure {

        console.log ("[Hello3] fun: a = %s\n", a);
    }

    function fun2 (uint a) public pure {

        console.log ("[Hello3] fun2: a = %s\n", a);
    }

    function ProxyFun (uint a) external view {

        // так вызывать external-функцию нельзя
        //fun (a);
        // только так
        this.fun (a);

        fun2 (a);
    }
}