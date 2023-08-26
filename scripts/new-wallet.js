const ethers = require('ethers')

module.exports = {
    newWallet() {
        return ethers.Wallet.createRandom()
    }
    
}