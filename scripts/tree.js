const { ethers } = require("ethers");
const { config } = require("dotenv");
const path = require("path");
config({ path: path.join(__dirname, "../.env.local") });
(async () => {
  const initCode = "600c38818103823d39033df3";
  const provider = new ethers.JsonRpcProvider(process.env.JSON_RPC);
  const wallet = ethers.Wallet.fromPhrase(process.env.MNEMONIC, provider);
  const signer = wallet;
  const receipts = {};
  const deploy = async (runtimeCode, value = 0) => {
    const input = {
      data: "0x" + initCode + runtimeCode,
    };
    const tx = await signer.sendTransaction(input);
    const rx = await tx.wait();
    console.log({ rx });
    receipts[rx.hash] = rx;
    return rx.hash;
  };
  const call = async (address, data, value = 0) => {
    const input = {
      data,
      to: address,
      value,
    };
    const tx = await signer.sendTransaction(input);
    const rx = await tx.wait();
    receipts[rx.hash] = rx;
    console.log({ rx });
    return rx.hash;
  };
  const divider = "6001353d35043d5260203df3";
  let receipt = await deploy(divider);
  let { contractAddress } = receipts[receipt];
  const code = await provider.getCode(contractAddress);
  console.log({ code });
  receipt = await call(
    contractAddress,
    ethers.solidityPacked(["uint256", "uint256"], [20, 5])
  );
})();

/**
 * Contracts
 *
 * Generic Init Code
 * 600c 0c
 * 38 cs 0c
 * 8181 cs 0c cs 0c
 * 03 cl cs 0c
 * 82 0c cl cs 0c
 * 3d 0 0c cl cs 0c
 * 39 cs 0c
 * 033df3
 * 600c38818103823d39033df3
 *
 * Divider
 * 600135 cd1
 * 3d35 cd0 cd1
 * 043d 0 x/y
 * 5260203df3
 * 6001353d35043d5260203df3
 *
 * Divider (log)
 * 0000 600135 cd1
 * 0020 3d35 cd0 cd1
 * 043d 0 x/y
 * 14
 * 6001353d35043d0a
 * 
 * Leaf
00 6020
02 3d
03 3d
04 3d
05 33
06 5a
07 fa
08 601b
0a 57
0b 3d
0c 51
0d 80
0e 15
0f 60
10 1b
11 57
12 80
13 3b
14 3d
15 81
16 3d
17 3d
18 85
19 3c
1a f3
1b 5b
1c fe

60203d3d3d335afa601b573d5180101b57803b3d813d3d853cf35bfe
 */
