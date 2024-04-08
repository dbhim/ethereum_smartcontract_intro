// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8;

// Uncomment this line to use console.log
import "hardhat/console.sol";



abstract contract DebugPrintContract {


    function GetContractName () internal virtual view returns (string memory);

    function PrintInfo () public payable {

        string memory msgStr = GetContractName();

        console.log ("[%s] gasleft = %s\n", msgStr, gasleft());
        console.log ("[%s] msg.sender = %s\n", msgStr, msg.sender);
        //console.log ("[%s] msg.sig = %s\n", msgStr, msg.sig);
        console.log ("[%s] msg.value = %s\n", msgStr, msg.value);
        //console.log ("[%s] msg.data = %s\n", msgStr, msg.data);

        console.log ("[%s] tx.gasprice = %s\n", msgStr, tx.gasprice);
        console.log ("[%s] tx.origin = %s\n", msgStr, tx.origin);

        console.log ("[%s] block.chainid = %s\n", msgStr, block.chainid);
        console.log ("[%s] block.coinbase = %s\n", msgStr, block.coinbase);
        //console.log ("[%s] block.difficulty = %s\n", msgStr, block.difficulty);
        console.log ("[%s] block.prevrandao = %s\n", msgStr, block.prevrandao);
        console.log ("[%s] block.gaslimit = %s\n", msgStr, block.gaslimit);
        console.log ("[%s] block.number = %s\n", msgStr, block.number);
        console.log ("[%s] block.timestamp = %s\n", msgStr, block.timestamp);
        console.log ("[%s] blockckhash(block.number) = %s\n", msgStr, uint(blockhash(block.number)));
        console.log ("[%s] blockckhash(block.number-1) = %s\n", msgStr, uint(blockhash(block.number-1)));
        console.log ("[%s] blockckhash(block.number+1) = %s\n", msgStr, uint(blockhash(block.number+1)));

        console.log ("[%s] codehash = %s\n", msgStr, uint(address(this).codehash));
        
        // При вызове из конструктора код будет пустым.
        PrintBytes (address(this).code);
    }

    function PrintBytes (bytes memory arr) public view {
        
        string memory msgStr = GetContractName();
        console.log ("[%s] arr: ", msgStr);
        /*
        string memory msgStr = contractName;
        console.log ("[%s] arr.length = %s\n", msgStr, arr.length);
        console.log ("[%s] arr\n", msgStr);
        for (uint i = 0; i < arr.length; ++i) {
            console.log ("%o\n", uint8(arr[i]));
        }
        console.log ("\n");
        */

        console.logBytes (arr);
    }

    function DebugPrint (uint a) public view {
        string memory msgStr = GetContractName();
        console.log ("[%s] %s\n", msgStr, a);
    }

    function DebugPrint (string memory a) public view {
        string memory msgStr = GetContractName();
        console.log ("[%s] %s\n", msgStr, a);
    }

    function DebugPrint (string memory s, uint a) public view {
        string memory msgStr = GetContractName();
        console.log ("[%s] %s %s\n", msgStr, s, a);
    }

    function DebugPrint (string memory s, uint a, uint b) public pure {
        console.log ("%s %s %s\n", s, a, b);
    }

    function DebugPrint (string memory s, address a) public view {
        string memory msgStr = GetContractName();
        console.log ("[%s] %s %s\n", msgStr, s, a);
    }

    function DebugPrint (string memory s, address a, uint b) public pure {
        console.log ("%s %s\n", s, a, b);
    }

}


library DebugStorageContract {

    function ReadStorageValue (uint addr) public view returns (uint value) {

        assembly {
                value := sload (addr)
            }
    }

    function WriteStorageValue (uint addr, uint value) public returns (uint prevValue) {
        
        assembly {
            prevValue := sload (addr)
            sstore (addr, value)
        }
    }

    function GetStorageSlot (uint[] storage a) internal pure returns (uint slot) {
        assembly {
            slot := a.slot
        }
    }

    function PrintStorage (uint addr, uint count) public view {

        console.log ("%s %s\n", addr, count);

        for (uint i = addr; i < count; ++i) {
            uint value = uint(ReadStorageValue (i));
            console.log ("%s: ", i);
            console.logAddress (address(uint160(value)));
        }
    }


}
