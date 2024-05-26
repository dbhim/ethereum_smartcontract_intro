Установить [Remix Desktop](https://github.com/ethereum/remix-desktop/releases)
или использовать [онлайн-версию](https://remix.ethereum.org/).

[Установить Node.js (с npm)](https://nodejs.org/en/download/).

Поставится куда-нибудь сюда `C:\Program Files\nodejs`.
Этот путь пропишется в переменной `Path`.
Должны стать доступны команды `node`, `npm`, `npx`.

Посмотреть установленные версии  
`> npm -v`  
10.5.0  
`> node -v`  
v20.11.1  

Для обновления установленного Node.js можно просто запустить новый инсталлятор. Для обновления npm выполнить:  
`> npm install -g npm`  

С помощью [`npm`](https://nodejs.org/en/learn/getting-started/an-introduction-to-the-npm-package-manager) устанавливаем необходимые пакеты локально (в текущий каталог в node_modules) или глобально (в каталог пользователя `%APPDATA%\npm\node_modules`):  
`> npm install`			- локальная установка  
`> npm install -g`		- глобальная установка  
`> npm list`  
`> npm list -g`  

Запуск установленного пакета через `npx`.



[Установка пакетов для разработки смартконтрактов](
https://hardhat.org/hardhat-runner/docs/getting-started)

В каталоге с проектом выполнить:  
`> npm install --save-dev hardhat`  
`> npx hardhat init`  
Выбрать "Create a JavaScript project" и установить дополнительно @nomicfoundation/hardhat-toolbox (npm install --save-dev "@nomicfoundation/hardhat-toolbox@^5.0.0").

Установить пакет для связи с IDE Remix  
`> npm install @remix-project/remixd`  
Последняя версия v0.6.29

В каталоге с проектом выполнить (в двух отдельных консолях) команды.

Запуск сервера remixd на стандартном адресе 127.0.0.1:65520 для подключения из Remix  
`> npx remixd -s .`  
Запуск тестовой сети hardhat на стандартном адресе http://127.0.0.1:8545 для подключения из Remix  
`> npx hardhat node`  

Иногда возникают проблемы с подключением - нужно перезагрузить запущенный сервер remixd.

После инициализации hardhat создался тестовый проект с контрактом и тестовым кодом. Проверить командами:  
`> npx hardhat compile`  
`> npx hardhat test`  


После инициализации и запуска к получившемуся окружению можно подключиться из Remix:
- на вкладке "File explorer" можно подключиться к workspace localhost (это будет папка, открытая в remixd)
- на вкладке "Deploy & run transactions" можно подключиться к окружению hardhat node.

Если запущена онлайн-версия Remix в браузере, то можно подключиться к Metamask (выбрать пункт WalletConnect). Таким образом транзакции будут посылаться через Metamask с выбранными в нём сетью и аккаунтом.

В Metamask можно выбрать текущую сеть. EVM сети можно подключить на сайте chainlist.org. Например, сеть [Mumbai](https://chainlist.org/chain/80001), сеть [Polygon Amoy](https://chainlist.org/chain/80002). Можно добавить сеть, вручную указав адрес. Например для локальной сети hardhat: http://localhost:8545.