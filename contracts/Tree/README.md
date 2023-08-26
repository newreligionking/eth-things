# Tree

Basically a fits-all pattern for protocols

It uses a central contract which is called directly by your users. This contract delegatecalls into the appropriate implementation contract based on the selector in msg.data. No state is read, only hashing of the selector data is used to figure out which address to call into.

The same deployer is used with all your deployments, this should be the point where you check for authorization (when deploying). Once the selector/contract pair is deployed with the deployer, users of your Dapp will be able to call the function at the new selector to interact with the contract. Just change the call signature on the frontend to the one of the new function.

example workflow:

```sol
/// Same storage semantics apply, here balance has the same slot in both implementations
contract Deposit {
    uint256 balance;

    function deposit() external payable returns (uint256 bal) {
        require(msg.value > 0, "Expensive");
        balance += msg.value;
        return balance;
    };
}
contract Withdraw {
    uint256 balance;
    function withdraw(uint256 amount) external returns (uint256 bal) {
        require(amount > 0, "Expensive");
        // No overflowcheck boss
        balance -= amount;
        payable(msg.sender).send(amount);
        return balance;
    };
}
```
The above contracts when deployed with this setup gives the following interface at the address of the proxy:
```sol
interface IDApp {
    function withdraw(uint256 amount) external returns (uint256 bal);
    function deposit() external payable returns (uint256 bal);
}
```

Now to upgrade, you write updates like these:
```sol
contract Deposit_v2 {
    function deposit_v2(uint256 amount) external payable returns (uint256 bal) {
        if (amount > msg.value) revert();
    }
}
```
After the new contract is deployed, calls to deploy_v2 will be routed to the newer contract. Note the difference in selectors, we never update the actual function body we create new functions.

The old functions are still available, so it's your responsibility to update the frontend. The interface becomes:
```sol
interface IDapp {
    function withdraw(uint256 amount) external returns (uint256 bal);
    function deposit() external payable returns (uint256 bal);
    function deposit_v2(uint256 amount) external payable returns (uint256 bal);
}
```