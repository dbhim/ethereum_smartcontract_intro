// SPDX-License-Identifier: UNLICENSED

// Ограничение на версию компилятора
pragma solidity >=0.8;

// Делаем видимыми в текущем файле конкретные сущности из другого файла.
import {DebugPrintContract, DebugStorageContract} from "./Debug.sol";

// Библиотека для отладочного вывода в тестовой сети.
import "hardhat/console.sol";

// Константа времени компиляции.
string constant DEMO_CONTRACT_NAME = "DemoContract";


// Библиотека - это контракт без состояния (все вызовы идут через delegatecall),
// для которого предоставляется упрощённый синтаксис вызова из других контрактов.
// Remix может автоматически деплоить контракт библиотеки (отдельной транзакцией)
// и подставлять адрес этого контракта в места вызова функций библиотеки.
// Если библиотека уже задеплоина, то можно указать Remix'у её адрес.
library DemoLibrary {

    function DLadd (uint a, uint b) public pure returns (uint) {
        return a + b;
    }
}


// Будет использоваться в качестве родительского контракта.
// Но может быть и задеплоен сам, т.к. не является абстрактным.
contract BaseContract {

    // Для существующего типа можно завести синоним.
    type ValueType is uint;

    // константу (const) надо инициализировать во время компиляции
    //uint constant baseVar;
    // неизменяемую переменную можно инициализировать в конструкторе контракта
    ValueType internal immutable _value;

    constructor (uint value) {

        // аналог asssert в других языках - используется для проверки инвариантов
        assert (address(this).balance == 0);

        // конвертация из значения исходного типа
        _value = ValueType.wrap(value);
    }

    // Возможна перегрузка функций по аргументам.
    function f () public pure {

    }

    function f (uint a) public pure {

    }

    // Можно определять собственные модификаторы функций.
    // Похожи на декораторы в Python.
    modifier NotNull (uint a) {

        // Проверка условия.
        // Если условие ложно, выполняется инструкция revert с указанной строкой.
        require(a != 0, "is null");
        
        _;  // вызов исходной функции
    }
}


// Контракт наследуется от двух контрактов.
contract DemoContract is BaseContract, DebugPrintContract {

    // В этом контракте для типа uint будут доступны функции библиотеки
    // с первым аргументом этого типа.
    using DemoLibrary for uint;

    using DebugStorageContract for *;

    // Константа должна быть проинициализирована во время компиляции.
    string constant contractName = DEMO_CONTRACT_NAME;

    // целочисленные беззнаковые переменные
    uint8 private ui8 = 0x8;
    uint16 private ui16 = 0x16;
    uint24 private ui24 = 0x24;
    // ...
    uint256 private ui256 = 0x256;

    // целочисленные знаковые переменные
    int8 private i8 = 0x18;
    //...
    int256 private i256 = 0x1256;

    // массивы байт фиксированной длины
    bytes1 private b1 = 0x01;
    bytes2 private b2 = 0x0202;
    bytes3 private b3 = 0x030303;
    bytes4 private b4 = 0x04040404;
    //...
    bytes32 private b32 = hex"0505050505050505050505050505050505050505050505050505050505050505";

    // массив фиксированной длины
    uint64[2] private uia2 = [0x010101010101, 0x02020202];

    // массив произвольной длины
    // В его слоте располагается текущая длина массива.
    // i-ый элемент располагается в слоте (keccak256(uida.slot) + i * elementSize)
    uint[] private uida;

    // массив байт произвольной длины
    bytes ba = hex"0102030405";

    // Для отображения отводится пустой слот.
    // Элемент с ключом key располагается в слоте keccak256(key, uumap.slot)
    mapping (uint => uint) uumap;

    struct Entry {
        uint256 a;
        uint8 b;
    }

    Entry[5] sea5;

    // Конструктор может быть только один.
    // Можно передавать аргументы в конструкторы базовых классов.
    constructor (uint a) payable BaseContract(a) {

        DebugPrint ("a = ", a);
        DebugPrint ("msg.gas = ", gasleft());

        DebugPrint ("1 + 2 = ", DemoLibrary.DLadd (1, 2));

        PrintInfo();
    }

    // Переопределяем виртуальную функцию из базового класса.
    function GetContractName () internal override pure returns (string memory) {
        
        return contractName;
    }

    function PureFunction (uint a) pure public NotNull(a) returns (uint) {
        console.log ("a = %d\n", a);
        return a + 1;
    }

    function TestBytes (bytes calldata a) public returns (bytes calldata) {

        //uint slot = DebugStorageContract.GetStorageSlot (b1);
        PrintBytes (a);

        PrintInfo();  
        return a;
    }

    function TestVariables () public {

        uint slot;
        uint offset;
        //assembly {slot := contractName.slot}
        //DebugPrint ("contractName slot: ", slot);

        // Демонстрация размещения статических переменных в storage

        assembly {  slot := ui8.slot        // адрес 256-битного слота в storage
                    offset := ui8.offset}   // смещение в байтах внутри слота
        DebugPrint ("ui8 slot, offset: ", slot, offset);

        assembly {  slot := ui16.slot
                    offset := ui16.offset}
        DebugPrint ("ui16 slot, offset: ", slot, offset);

        assembly {  slot := ui24.slot
                    offset := ui24.offset}
        DebugPrint ("ui24 slot, offset: ", slot, offset);

        assembly {  slot := ui256.slot
                    offset := ui256.offset}
        DebugPrint ("ui256 slot, offset: ", slot, offset);

        assembly {  slot := i8.slot
                    offset := i8.offset}
        DebugPrint ("i8 slot, offset: ", slot, offset);

        assembly {  slot := i256.slot
                    offset := i256.offset}
        DebugPrint ("i256 slot, offset: ", slot, offset);

        assembly {  slot := b1.slot
                    offset := b1.offset}
        DebugPrint ("b1 slot, offset: ", slot, offset);

        assembly {  slot := b2.slot
                    offset := b2.offset}
        DebugPrint ("b2 slot, offset: ", slot, offset);
        
        assembly {  slot := b3.slot
                    offset := b3.offset}
        DebugPrint ("b3 slot, offset: ", slot, offset);

        assembly {  slot := b4.slot
                    offset := b4.offset}
        DebugPrint ("b5 slot, offset: ", slot, offset);

        assembly {  slot := b32.slot
                    offset := b32.offset}
        DebugPrint ("b32 slot, offset: ", slot, offset);

        assembly {  slot := uia2.slot
                    offset := uia2.offset}
        DebugPrint ("uia2 slot, offset: ", slot, offset);

        assembly {  slot := uida.slot
                    offset := uida.offset}
        DebugPrint ("uida slot, offset: ", slot, offset);

        assembly {  slot := ba.slot
                    offset := ba.offset}
        DebugPrint ("ba slot, offset: ", slot, offset);

        assembly {  slot := uumap.slot
                    offset := uumap.offset}
        DebugPrint ("uumap slot, offset: ", slot, offset);

        assembly {  slot := sea5.slot
                    offset := sea5.offset}
        DebugPrint ("sea5 slot, offset: ", slot, offset);

        DebugStorageContract.PrintStorage (0, 12);


        // Демонстрация размещения динамических переменных в storage

        uint uidaSlot;
        assembly { uidaSlot := uida.slot }

        // в слоте массива сейчас нулевая длина
        DebugPrint ("uida slot: ", uidaSlot, DebugStorageContract.ReadStorageValue (uidaSlot));

        // помещаем два элемента
        uida.push (1111111111111111111111111111111111111111111112222);
        uida.push (2222222222222222222222222222222222222222222223333);
        
        // в слоте массива сейчас 2
        DebugPrint ("uida slot: ", uidaSlot, DebugStorageContract.ReadStorageValue (uidaSlot));

        for (uint i = 0; i < uida.length; ++i) {
            // высчитываем адрес слота для i-го элемента
            uint elementSlot = uint256(keccak256(abi.encodePacked(uidaSlot))) + i * 1;
            // выводим значение по адресу
            DebugPrint ("uida element slot ", elementSlot, DebugStorageContract.ReadStorageValue (elementSlot));
        }


        uint uumapSlot;
        assembly { uumapSlot := uumap.slot }

        // в слоте отображения всегда 0
        DebugPrint ("uumap slot: ", uumapSlot, DebugStorageContract.ReadStorageValue (uumapSlot));

        // помещаем два элемента
        uumap[0] = 3333333333333333333333333333333333333333333334444;
        uumap[1] = 4444444444444444444444444444444444444444444445555;

        // высчитываем адрес слота для uumap[0]
        uint element0Slot = uint256(keccak256(abi.encodePacked(uint(0), uumapSlot)));
        // выводим значение по адресу
        DebugPrint ("uumap[0] element slot ", element0Slot, DebugStorageContract.ReadStorageValue (element0Slot));

        // высчитываем адрес слота для uumap[1]
        uint element1Slot = uint256(keccak256(abi.encodePacked(uint(1), uumapSlot)));
        // выводим значение по адресу
        DebugPrint ("uumap[1] element slot ", element1Slot, DebugStorageContract.ReadStorageValue (element1Slot));


        // Перепишем элементом динамического массива uida элемент отображения uumap.
        // Адреса их слотов мы только что подсчитали.
        // Слоты элементов динамического массива идут последовательно, начиная с некоторого.
        // Поэтому надо просто вычислить индекс массива, который будет попадать
        // в нужный элемент отображения uumap.

        // Переписываем поле длины массива максимальным значением
        DebugStorageContract.WriteStorageValue (uidaSlot, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        // адрес слота 0-го элемента массива
        uint uidaElement0Slot = uint256(keccak256(abi.encodePacked(uidaSlot)));
        
        // высчитываем индекс элемента массива, который попадает в тот же слот, что и uumap[1]
        uint writeIndex;
        unchecked {
            writeIndex = element1Slot - uidaElement0Slot;
        }

        DebugPrint ("writeIndex: ", writeIndex);

        // выводим элемент до перезаписи
        DebugPrint ("uumap[1]: ", uumap[1]);
        // перезаписываем
        uida[writeIndex] = 5555555555555555555555555555555555555555555556666;
        // выводим тот же элемент после перезаписи
        DebugPrint ("uumap[1]: ", uumap[1]);

        // Можно заметить, что mapping также позволяет писать по произвольным адресам
        // в storage, к тому же в нём нет ограничений наподобие длины массива.
        // Но если мы хотим переписать элемент в storage по фиксированному адресу,
        // то вычислительно невозможно подобрать ключ, который отобразиться на этот элемент.

    }

}
