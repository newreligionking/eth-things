TransactionRequest
A transaction request describes a transaction that is to be sent to the network or otherwise processed.

All fields are optional and may be a promise which resolves to the required type.

transactionRequest.to ⇒ string | Promise< string >
The address (or ENS name) this transaction it to.

transactionRequest.from ⇒ string< Address > | Promise< string< Address > >
The address this transaction is from.

transactionRequest.nonce ⇒ number | Promise< number >
The nonce for this transaction. This should be set to the number of transactions ever sent from this address.

transactionRequest.data ⇒ DataHexString | Promise< DataHexString >
The transaction data.

transactionRequest.value ⇒ BigNumber | Promise< BigNumber >
The amount (in wei) this transaction is sending.

transactionRequest.gasLimit ⇒ BigNumber | Promise< BigNumber >
The maximum amount of gas this transaction is permitted to use.

If left unspecified, ethers will use estimateGas to determine the value to use. For transactions with unpredicatable gas estimates, this may be required to specify explicitly.

transactionRequest.gasPrice ⇒ BigNumber | Promise< BigNumber >
The price (in wei) per unit of gas this transaction will pay.

This may not be specified for transactions with type set to 1 or 2, or if maxFeePerGas or maxPriorityFeePerGas is given.

transactionRequest.maxFeePerGas ⇒ BigNumber | Promise< BigNumber >
The maximum price (in wei) per unit of gas this transaction will pay for the combined EIP-1559 block's base fee and this transaction's priority fee.

Most developers should leave this unspecified and use the default value that ethers determines from the network.

This may not be specified for transactions with type set to 0 or if gasPrice is specified..

transactionRequest.maxPriorityFeePerGas ⇒ BigNumber | Promise< BigNumber >
The price (in wei) per unit of gas this transaction will allow in addition to the EIP-1559 block's base fee to bribe miners into giving this transaction priority. This is included in the maxFeePerGas, so this will not affect the total maximum cost set with maxFeePerGas.

Most developers should leave this unspecified and use the default value that ethers determines from the network.

This may not be specified for transactions with type set to 0 or if gasPrice is specified.

transactionRequest.chainId ⇒ number | Promise< number >
The chain ID this transaction is authorized on, as specified by EIP-155.

If the chain ID is 0 will disable EIP-155 and the transaction will be valid on any network. This can be dangerous and care should be taken, since it allows transactions to be replayed on networks that were possibly not intended. Intentionally-replayable transactions are also disabled by default on recent versions of Geth and require configuration to enable.

transactionRequest.type ⇒ null | number
The EIP-2718 type of this transaction envelope, or null for to use the network default. To force using a lagacy transaction without an envelope, use type 0.

transactionRequest.accessList ⇒ AccessListish
The AccessList to include; only available for EIP-2930 and EIP-1559 transactions.

TransactionResponseinherits Transaction
A TransactionResponse includes all properties of a Transaction as well as several properties that are useful once it has been mined.

transaction.blockNumber ⇒ number
The number ("height") of the block this transaction was mined in. If the block has not been mined, this is null.

transaction.blockHash ⇒ string< DataHexString< 32 > >
The hash of the block this transaction was mined in. If the block has not been mined, this is null.

transaction.timestamp ⇒ number
The timestamp of the block this transaction was mined in. If the block has not been mined, this is null.

transaction.confirmations ⇒ number
The number of blocks that have been mined (including the initial block) since this transaction was mined.

transaction.raw ⇒ string< DataHexString >
The serialized transaction. This may be null as some backends do not populate it. If this is required, it can be computed from a TransactionResponse object using this cookbook recipe.

transaction.wait( [ confirms = 1 ] ) ⇒ Promise< TransactionReceipt >
Resolves to the TransactionReceipt once the transaction has been included in the chain for confirms blocks. If confirms is 0, and the transaction has not been mined, null is returned.

If the transaction execution failed (i.e. the receipt status is 0), a CALL_EXCEPTION error will be rejected with the following properties:

error.transaction - the original transaction
error.transactionHash - the hash of the transaction
error.receipt - the actual receipt, with the status of 0
If the transaction is replaced by another transaction, a TRANSACTION_REPLACED error will be rejected with the following properties:

error.hash - the hash of the original transaction which was replaced
error.reason - a string reason; one of "repriced", "cancelled" or "replaced"
error.cancelled - a boolean; a "repriced" transaction is not considered cancelled, but "cancelled" and "replaced" are
error.replacement - the replacement transaction (a TransactionResponse)
error.receipt - the receipt of the replacement transaction (a TransactionReceipt)
Transactions are replaced when the user uses an option in their client to send a new transaction from the same account with the original nonce. This is usually to speed up a transaction or to cancel one, by bribing miners with additional fees to prefer the new transaction over the original one.

transactionRequest.type ⇒ number
The EIP-2718 type of this transaction. If the transaction is a legacy transaction without an envelope, it will have the type 0.

transactionRequest.accessList ⇒ AccessList
The AccessList included, or null for transaction types which do not support access lists.

TransactionReceipt
receipt.to ⇒ string< Address >
The address this transaction is to. This is null if the transaction was an init transaction, used to deploy a contract.

receipt.from ⇒ string< Address >
The address this transaction is from.

receipt.contractAddress ⇒ string< Address >
If this transaction has a null to address, it is an init transaction used to deploy a contract, in which case this is the address created by that contract.

To compute a contract address, the getContractAddress utility function can also be used with a TransactionResponse object, which requires the transaction nonce and the address of the sender.

receipt.transactionIndex ⇒ number
The index of this transaction in the list of transactions included in the block this transaction was mined in.

receipt.type ⇒ number
The EIP-2718 type of this transaction. If the transaction is a legacy transaction without an envelope, it will have the type 0.

receipt.root ⇒ string
The intermediate state root of a receipt.

Only transactions included in blocks before the Byzantium Hard Fork have this property, as it was replaced by the status property.

The property is generally of little use to developers. At the time it could be used to verify a state transition with a fraud-proof only considering the single transaction; without it the full block must be considered.

receipt.gasUsed ⇒ BigNumber
The amount of gas actually used by this transaction.

receipt.effectiveGasPrice ⇒ BigNumber
The effective gas price the transaction was charged at.

Prior to EIP-1559 or on chains that do not support it, this value will simply be equal to the transaction gasPrice.

On EIP-1559 chains, this is equal to the block baseFee for the block that the transaction was included in, plus the transaction maxPriorityFeePerGas clamped to the transaction maxFeePerGas.

receipt.logsBloom ⇒ string< DataHexString >
A bloom-filter, which includes all the addresses and topics included in any log in this transaction.

receipt.blockHash ⇒ string< DataHexString< 32 > >
The block hash of the block that this transaction was included in.

receipt.transactionHash ⇒ string< DataHexString< 32 > >
The transaction hash of this transaction.

receipt.logs ⇒ Array< Log >
All the logs emitted by this transaction.

receipt.blockNumber ⇒ number
The block height (number) of the block that this transaction was included in.

receipt.confirmations ⇒ number
The number of blocks that have been mined since this transaction, including the actual block it was mined in.

receipt.cumulativeGasUsed ⇒ BigNumber
For the block this transaction was included in, this is the sum of the gas used by each transaction in the ordered list of transactions up to (and including) this transaction.

This is generally of little interest to developers.

receipt.byzantium ⇒ boolean
This is true if the block is in a post-Byzantium Hard Fork block.

receipt.status ⇒ number
The status of a transaction is 1 is successful or 0 if it was reverted. Only transactions included in blocks post-Byzantium Hard Fork have this property.