import { ethers } from "ethers";

export const getSigner = (accountIndex) => {
  return provider.getSigner(accountIndex);
};

export const provider = new ethers.providers.Web3Provider(web3Provider);

export const signer = getSigner(0);

export const deploy = async (code, endowment) => {
  const transaction = await signer.sendTransaction({
    to: null,
    data: code,
    value: endowment,
  });
  const receipt = transaction.wait();
  console.log(receipt);
};
