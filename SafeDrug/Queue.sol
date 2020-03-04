pragma solidity ^0.5.14;

/// @title Contratto che implementa una struttura dati coda
/// @notice Operazioni di aggiunta, rimozione e restituzione del 1° elemento della coda

contract Queue {
    mapping(uint256 => uint) queue;
    uint256 first = 1;
    uint256 last = 0;

    function enqueue(uint data) public {
        last += 1;
        queue[last] = data;
    }

    function dequeue() public returns (uint data) {
        require(last >= first);  // non-empty queue
        data = queue[first];
        delete queue[first];
        first += 1;
        return data;
    }

    function getFirstElement () public view returns (uint data) {
        require(last >= first);  // non-empty queue
        data = queue[first];
        return data;
    }
}
