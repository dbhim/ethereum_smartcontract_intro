// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


import "./Hello.sol";
import "./Debug.sol";

import "hardhat/console.sol";


// Контракт для создания других контрактов из байткода.
abstract contract FactoryFromBytecode {

    function deploy (bytes calldata bytecode) public returns (address addr) {

        // Копируем байты из входных данных в память.
        bytes memory implInitCode = bytecode;
        //uint bytecodeSize = bytecode.length;
        assembly {
            let encoded_data := add(0x20, implInitCode)
            let encoded_size := mload(implInitCode)
            addr := create (0, encoded_data, encoded_size)
        }

    }

    function deploy2 (uint salt, bytes calldata bytecode) public returns (address addr)  {
        bytes memory implInitCode = bytecode;
        
        uint bytecodeSize = bytecode.length;
        uint encoded_size;
        assembly {
            // Первые 20 байт в массиве - его длина.

            // получаем адрес в памяти байткода
            let encoded_data := add(0x20, implInitCode) 
            // считываем из памяти длину байткода
            encoded_size := mload(implInitCode)
            addr := create2(0, encoded_data, encoded_size, salt)
        }
        console.log ("%s %s %s\n", addr, encoded_size, bytecodeSize);

    }
}


contract CallContract is DebugPrintContract, FactoryFromBytecode {

    uint startValue = 111110;

    constructor () payable {

        DebugPrint ("gasleft: ", gasleft());

    }

    function GetContractName () internal override pure returns (string memory) {
        return "CallContract";
    }

    function CreateHello (uint gas) public {
        
        string memory msgStr = GetContractName();

        // Создаём новый контракт HelloWorld инструкцией create.
        // И передаём ему с нашего баланса 1 ether.
        HelloWorld hc = (new HelloWorld){value: 1 ether} ();
        console.log ("[%s] Create hello: %s\n", msgStr, address(hc));

        // Вызов функций возможен через переменную с типом контракта.
        // Тогда компилятор самостоятельно сформирует данные для инструкции call.

        // В вызов функции Hello передаётся весь оставшийся газ.
        hc.Hello (1);

        // Вызов функции Hello с передачей эфира и указанием газа.
        hc.Hello{value: 1 ether, gas: 5000} (2);
        
        // Если в вызов передать слишком мало газа, то он закончится с ошибкой,
        // инстукций call вернёт false и код компилятор в этом месте проверит это
        // и вызовет revert.
        //hc.Hello{value: 1 ether, gas: 100} (3);
        hc.Hello{value: 1 ether, gas: gas} (4);

        // Функции можно вызывать через низкоуровневый интерфейс для адреса.
        // Тогда входные данные нужно формировать самостоятельно

        // Передём пустые входные данные - вызовется функция receive.
        (bool retCode, bytes memory result) = address(hc).call{value: 1 ether, gas: gasleft()} ("");
        console.log ("[%s] res = %s\n", msgStr, retCode);

        // Передаём селектор несуществующей функции - вызовется функция fallback.
        (retCode, result) = address(hc).call{value: 1 ether} (abi.encodeWithSignature("Hello(uint)", 5));
        console.log ("[%s] res = %s\n", msgStr, retCode);

        // Вызов функции Hello с аргументом 6
        (retCode, result) = address(hc).call{value: 1 ether} (abi.encodeWithSignature("Hello(uint256)", 6));
        console.log ("[%s] res = %s\n", msgStr, retCode);

        // Вызов функции ShowStorageValue, которая работает с постоянным хранилищем контракта.
        // через call
        hc.ShowStorageValue();
        // через delegatecall
        (retCode, result) = address(hc).delegatecall (abi.encodeWithSignature("ShowStorageValue()"));
        console.log ("[%s] res = %s\n", msgStr, retCode);


        hc.SelfDestroy();
    }

    function CreateHello2 () public {
        
        string memory msgStr = GetContractName();

        // Создаём новый контракт HelloWorld инструкцией create.
        HelloWorld hello1 = (new HelloWorld){value: 1 ether} ();
        console.log ("[%s] Create hello1: %s\n", msgStr, address(hello1));
        hello1.SelfDestroy();

        // Создаём новый контракт HelloWorld инструкцией create2.
        HelloWorld hello2 = (new HelloWorld){value: 1 ether, salt: hex"01020304"} ();
        console.log ("[%s] Create hello2: %s\n", msgStr, address(hello2));
        hello2.SelfDestroy();

    }

    // Создаёт контракт HelloWorld из переданного байткода.
    // Надо передать код инициализации. Можно посмотреть этот код в Remix.
    function CreateHello3 (bytes calldata initBytecode) public {
        
        PrintBytes (initBytecode);

        HelloWorld hello3 = HelloWorld (payable(deploy (initBytecode)));
        DebugPrint ("hello3: ", uint(uint160(address(hello3))));
        //hello3.Hello (1);
    }

    function CreateHello4 (uint salt, bytes calldata initBytecode) public {
        
        PrintBytes (initBytecode);

        HelloWorld hello4 = HelloWorld (payable(deploy2 (salt, initBytecode)));
        DebugPrint ("hello3: ", uint(uint160(address(hello4))));
        //hello4.Hello (1);
    }

}


contract CallContract2 is DebugPrintContract {

    uint startValue = 222220;

    constructor () payable {

    }

    function GetContractName () internal override pure returns (string memory) {
        return "CallContract2";
    }

    // Вызов с помощью call в другом контракте функции, вызывающей revert.
    function CallRevert () public {

        string memory msgStr = GetContractName();

        HelloWorld2 hc = (new HelloWorld2) ();

        // Вызываем разными инструкциями и с разными аргументами функцию Revert.
        // Она изменяет значение в storage и при некоторых аргументах вызывает revert.
        
        // Если использовать низкоуровневый вызов для адреса,
        // то ошибки в текущей функции не будет.
        DebugPrint ("call Revert(0)");
        (bool retCode, bytes memory result) = address(hc).call{value: 0 ether} (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("call Revert(0)");
        (retCode, result) = address(hc).call{value: 0 ether} (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("call Revert(1)");
        (retCode, result) = address(hc).call{value: 0 ether} (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("call Revert(1)");
        (retCode, result) = address(hc).call{value: 0 ether} (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);

        // А так будет ошибка текущей функции.
        // Транзакция к этой функции закончится с ошибкой,
        // но отладочный вывод до этого места увидим.
        DebugPrint ("hc.Revert");
        hc.Revert(1);

    }

    // Вызов с помощью staticcall в другом контракте функции, вызывающей revert.
    function StaticcallRevert () public {

        string memory msgStr = GetContractName();

        HelloWorld2 hc = (new HelloWorld2) ();
        
        // Если с помощью staticcall вызвать функцию, изменяющую состояние,
        // то функцию завершится с ошибкой, исчерпав весь переданный ей газ.
        // Поэтому если передавать в вызовы весь газ, то первый же вызов
        // с ошибкой исчерпает весь газ транзакции.
        DebugPrint ("staticcall Revert(0) gasleft = ", gasleft());
        (bool retCode, bytes memory result) = address(hc).staticcall (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(0) gasleft = ", gasleft());
        
        // на этот вызов уже газа не хватит
        (retCode, result) = address(hc).staticcall (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(1) gasleft = ", gasleft());
        (retCode, result) = address(hc).staticcall (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(1) gasleft = ", gasleft());
        (retCode, result) = address(hc).staticcall (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);

        DebugPrint ("hc.Revert");
        hc.Revert(1);

    }

    // Вызов с помощью staticcall в другом контракте функции, вызывающей revert.
    function StaticcallRevert2 () public {

        string memory msgStr = GetContractName();

        HelloWorld2 hc = (new HelloWorld2) ();
        
        // Здесь в вызов staticcall передаём небольшое количество газа.
        // В каждом вызове еесь переданный газ сгорит, но в текущем вызове газ
        // останется для следующих вызовов.
        DebugPrint ("staticcall Revert(0) gasleft = ", gasleft());
        (bool retCode, bytes memory result) = address(hc).staticcall{gas: 1000} (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(0) gasleft = ", gasleft());
        (retCode, result) = address(hc).staticcall{gas: 1000} (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(1) gasleft = ", gasleft());
        (retCode, result) = address(hc).staticcall{gas: 1000} (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("staticcall Revert(1) gasleft = ", gasleft());
        (retCode, result) = address(hc).staticcall{gas: 1000} (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);

        DebugPrint ("hc.Revert");
        hc.Revert(1);

    }

    // Вызов с помощью delegatecall в другом контракте функции, вызывающей revert.
    function DelegatecallRevert () public {

        string memory msgStr = GetContractName();

        HelloWorld2 hc = (new HelloWorld2) ();
        
        // Вызываем функцию через delegatecall.
        // Значит функция изменит в storage текущего контракта переменную startValue.

        // Первые два вызова пройдут удачно
        DebugPrint ("delegatecall Revert(0)");
        (bool retCode, bytes memory result) = address(hc).delegatecall (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("delegatecall Revert(0)");
        (retCode, result) = address(hc).delegatecall (abi.encodeWithSignature("Revert(uint256)", 0));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        // к этом моменту переменная 2 раза изменится

        // Следующие два вызова пройдут неудачно.
        DebugPrint ("delegatecall Revert(1)");
        (retCode, result) = address(hc).delegatecall (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        DebugPrint ("delegatecall Revert(1)");
        (retCode, result) = address(hc).delegatecall (abi.encodeWithSignature("Revert(uint256)", 1));
        console.log ("[%s] res = %s\n", msgStr, retCode);
        // т.е. после них значение переменной не изменится.


        // Здесь транзакция завершится с ошибкой,
        // а значит отбросятся все изменения состояния.
        // Даже те, которые произошли в двух первых (удачных) вызовах.
        DebugPrint ("hc.Revert");
        hc.Revert (1);

    }

    function Resend () public payable {

        HelloWorld2 hc = (new HelloWorld2) ();

        // Пришедшие деньги сразу можем передать другому адресу
        bool ret = payable(address(hc)).send (msg.value);
        DebugPrint ("send: ret = ", ret ? uint(1) : uint(0));
    }

    function Retransfer () public payable {

        HelloWorld2 hc = (new HelloWorld2) ();

        // Пришедшие деньги сразу можем передать другому адресу
        payable(address(hc)).transfer (msg.value);
    }

}


interface IFunInterface {

    function fun (uint a) external;
}


interface IHelloWorld3 {

    // В сигнатуре указываем модификатор payable.
    // Хотя в контракте его у этой функции нет.
    // Но модификаторы не входят в сигнатуру для формирования селектора.
    function NotPayableFunction() external payable;
}


contract CallContract3 {

    function ResendNotPayableFunction () public payable {

        HelloWorld3 hc = (new HelloWorld3) ();

        // Передаём деньги в функцию receive.
        (bool retCode, bytes memory result) = payable(address(hc)).call{value: msg.value / 3} ("");
        console.log ("[CallContract3] receive: retCode = %s\n", retCode);

        // Передаём деньги в функцию NotPayableFunction - вернёт false.
        (retCode, result) = payable(address(hc)).call{value: msg.value / 3} (abi.encodeWithSignature("NotPayableFunction()"));
        console.log ("[CallContract3] NotPayableFunction: retCode = %s\n", retCode);

        // Вызываем функцию NotPayableFunction без денег - вернёт true.
        IHelloWorld3(address(hc)).NotPayableFunction();

        // Передаём деньги в функцию NotPayableFunction - вернёт false.
        // Поэтому будет ошибка текущего вызова.
        IHelloWorld3(address(hc)).NotPayableFunction{value: msg.value / 3}();
    }

    function fun (uint a) external {

        console.log ("[CallContract3] fun: a = %s\n", a);
    }

    function DemoFun() public {

        HelloWorld2 hello2 = (new HelloWorld2) ();
        HelloWorld3 hello3 = (new HelloWorld3) ();

        IFunInterface(address(hello2)).fun (1);
        IFunInterface(address(hello3)).fun (2);
        IFunInterface(address(this)).fun (3);

        // При вызове с помощью инструкции call
        // внутри будет вызвана функция HelloWorld3.fun
        hello3.ProxyFun (4);

        // При вызове с помощью инструкции delegatecall
        // внутри будет вызвана функция CallContract3.fun
        address(hello3).delegatecall (abi.encodeWithSignature("ProxyFun(uint256)", 5));
    }

}