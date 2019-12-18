var HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = '';



module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,//8545 la precedente
      network_id: "*" // Match any network id
    },
    compilers: {
      solc: {
        version: "0.5.6",
      },
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, "https://ropsten.infura.io/v3/53da5774bc2d410c90cc1e4c19d84dc4")
      },
      network_id: 3,
      gas: 4000000 //make sure this gas allocation isn't over 4M, which is the max
    },
  rpc: {
    host: 'localhost',
    post: 8080
  },
  rinkeby: {
    provider: function() {
      return new HDWalletProvider(MNEMONIC, "https://rinkeby.infura.io/v3/53da5774bc2d410c90cc1e4c19d84dc4");
    },
    network_id: 4,
    gasPrice: 20000000000,
    gas: 3716887
  },
  kovan: {
    provider: function() {
      return new HDWalletProvider(MNEMONIC, "https://kovan.infura.io/v3/53da5774bc2d410c90cc1e4c19d84dc4");
    },
    network_id: 42,
    gasPrice: 20000000000,
    gas: 3716887
  },
  main: {
    provider: function() {
      return new HDWalletProvider(MNEMONIC, "https://mainnet.infura.io/v3/53da5774bc2d410c90cc1e4c19d84dc4");
    },
    network_id: 1,
    gasPrice: 20000000000, // 20 GWEI
    gas: 3716887 // gas limit, set any number you want
  }
}
};
