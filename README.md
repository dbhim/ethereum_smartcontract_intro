[https://github.com/dbhim/ethereum_smartcontract_intro](https://github.com/dbhim/ethereum_smartcontract_intro)  
[https://gitverse.ru/dbhim/ethereum_smartcontract_intro](https://gitverse.ru/dbhim/ethereum_smartcontract_intro)

Здесь представлено небольшое введение в блокчейн, Ethereum, смарт-контракты, Solidity. Это материалы занятия, которое было проведено для студентов старших курсов по специальности "компьютерная безопасность". Предполагается, что у обучающихся имеются соответствующие знания по программированию, базам данных, криптографии, безопасности, эксплуатации уязвимостей. Исходя из этого отбирался материал для занятия и способ его представления.

### Ethereum

[Описание платформы Ethereum](./ethereum_intro.md).

Для написания смарт-контрактов можно использовать ассемблер. Но обычно используются высокоуровневые языки: Solidity, Vyper, Yul.

[Описание Solidity](./solidity.md).

Для разработки, тестирования, разворачивания смарт-контрактов используются фреймворки Brownie (Python), Hardhat (JS), Truffle.

[Описание настройки связки hardhat и Remix](./ethereum_devel.md)



### Примеры

Я постарался проиллюстрировать примерами основные синтаксические возможности языка Solidity, а также некоторые тонкие места взаимодействия с контрактами. Следует прочитать код примеров с комментариями, повызывать методы контрактов, проанализировать отладочный вывод, сопоставить вывод с исходным кодом.


#### 1_DemoContract.sol

Пример демонстрирует следующие возможности:
- определение контракта;
- наследование контрактов;
- абстрактные контракты;
- библиотеки;
- встроенные типы данных;
- константы времени компиляции (`constant`) и времени исполнения (`constant`, `immutable`);
- методы и поля контракта, их модификаторы видимости и константности;
- инициализация полей контракта;
- конструктор контракта;
- перегрузка функций;
- собственные модификаторы функций;
- проверка условий в run-time (`require`, `assert`);
- размещение данных в storage;
- перезапись элементов в storage через переполнение динамического буфера

Для тестирования примера выполнить:
- задеплоить контракт `DemoContract` с нулевым и ненулевым количеством эфира;
- вызвать `PureFunction` с нулевым и ненулевым аргументом;
- вызвать `TestBytes`;
- вызвать `TestVariables`.


#### 2_Deposit.sol

Пример реализует простую функциональность по размещению депозитов пользователей с выплатой процентов.

Пример демонстрирует следующие возможности:
- приём монет от пользователей;
- передача монет пользователям;
- выплата процентов в зависимости от прошедшего времени;
- генерация событий.

Для тестирования примера выполнить:
- задеплоить контракт `DepositContract` с 1 эфиром;
- положить деньги на контракт вызовом функции `deposit` с 1 эфиром;
- проверить свой баланс вызовом функции `balanceOf`;
- забрать деньги с контракта вызовом `withdraw`;
- положить деньги с разных адресов и забрать все деньги вызовом функции `destroy` с адреса владельца.


#### 3_Call.sol

Пример иллюстрирует создание в контрактах других контрактов и вызов их функций.

Пример демонстрирует следующие возможности:
- создание контрактов через оператов `new`;
- вызов функций через переменную с типом контракта;
- низкоуровневый вызов функций адреса;
- интерфейсы;
- создание контрактов инструкциями `create`, `create2`.


Для тестирования примера выполнить:
- задеплоить контракт `CallContract` с 10 эфирами;
- вызвать функцию `CreateHello` с аргументом 5000;
- вызвать функцию `CreateHello` с аргументом 1000;
- вызвать функцию `CreateHello` с аргументом 100;
- два раза вызвать функцию `CreateHello2`: адрес `hello1` будет меняться, адрес `hello2` будет одинаковым;
- вызвать функцию `CreateHello3`, в качестве аргумента передать байткод контракта `HelloWorld` (можно сделать деплой контракта `HelloWorld` и скопировать его из транзакции из поля input);
- вызвать функцию `CreateHello4`, в качестве аргумента передать некоторое число (salt) и байткод контракта `HelloWorld`;
- задеплоить контракт `CallContract2`;
- вызвать функцию `CallRevert`;
- вызвать функцию `StaticcallRevert`;
- вызвать функцию `StaticcallRevert2`;
- вызвать функцию `DelegatecallRevert` 2 раза;
- вызвать функцию `Resend` с 1 и 2 эфирами;
- вызвать функцию `Retransfer` с 1 и 2 эфирами;
- задеплоить контракт `CallContract3`;
- вызвать функцию `ResendNotPayableFunction` с 6 эфирами;
- вызвать функцию `DemoFun`.



### Задания

В отдельном [репозитории](../../../ethereum_smartcontract_intro_vuln) доступны уязвимые контракты, к которым следует написать эксплоиты.
