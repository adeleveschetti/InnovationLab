# POC_0.2

This is the first draft of the POC that we are going to develop on the case study of CIR Food.
In this very first version was implemented only the contract that manages the interaction between the suppliers and the "purchasing department", and the JavaScript interface that calls the contract and its methods to write directly on the blockchain.

## More info

The contract can work on the main Ethereum net but it has not been optimized to do it for the moment.
This prototype was designed and developed to be tested on a local blockchain created using specific framework and setting the web3Provider as localhost(see below for details).

## Tasks implemented

The tasks currently implemented are as follows:
  - Request addition(public but callable only from owner and other constraints)
  - Offer addition with deposit(public but callable only for open request and other constraints)
  - Close Request(public but callable only from owner and other constraints)
  - Select best offer and refund deposit for losers(private, callable only by the contract)
  - Issuing of the order(private, with relative constraints)
  - Check of order reception(with relative constraints)
  - Final check from owner and refund deposit fo winner(with relative constraints)

The owner is the one who created the contract.
Each tasks has the own method in the contract and only the public methods can be called from external actors.


## Tests performed and results

First tests were carried out at command lines in the console of the development environment, then the javascript code was written to manage input from external sources, in this case input from a web page with forms and buttons.
The web page was created exclusively to have input sources and to have feedback on the correct writing and reading of data on the blockchain.

Through Ganache we then saw the "physical" creation of the blocks and the distribution of the individual transactions within it.

## Development information

The prototype was developed on macOS v10.14.2; the contract written in solidity ^0.5.0 and compiled and deployed with Truffle v5.0.0-beta.2.

## Tool set used

* [HomeBrew](https://brew.sh/index_it) - HomeBrew is package manager for macOS. It helps you to install stuff like packages that are not provided by Apple.(only for macOS)
* [Geth](https://github.com/ethereum/go-ethereum/wiki/geth) - Geth or go-ethereum is a command line interface, which allows you to run and operate ethereum node.
* [Ganache](https://truffleframework.com/ganache) - Ganache is an ethereum blockchain emulator that you can use for the development purpose.
* [NodeJS and NPM](https://nodejs.org/it/) - NodeJS is a server-side JavaScript platform to create apps that will help to communicate with your ethereum node.
* [Truffle](https://truffleframework.com) - Truffle is build framework used to compile, test and deploy your smart contract.
* [MetaMask](https://metamask.io) - MetaMask allows you to run Ethereum dApps right in your browser without running a full Ethereum node.
* [Web3.js](https://github.com/ethereum/web3.js/) - Web3.js is a collection of libraries which allow you to interact with a local or remote ethereum node, using a HTTP or IPC connection.
* [Chai and Mocha]() - JavaScript test framework.

## Consideration and next step

As already mentioned, this is the very first prototype of POC realized, therefore it is not optimized, not bug free and contains several elements of bad programming; but the purpose of this little work was to make contact with this technology and its potential.

The next step will be to improve the code and make it suitable to be tested on global test networks (Ropsten) and test it on them while waiting for the new specifications.(Did it)

## Authors

* **Simone Siena**
