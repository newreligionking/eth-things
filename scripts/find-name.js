const ethers = require("ethers");
// const { output } = require("./compile");

(async () => {
  const name = "add(uint256,uint256)";
  console.log(ethers);
  const selector = ethers.id(name).slice(0, 10);
  const desired_selector = "0xdeaddead";
  console.log({ selector, desired_selector });
  let count = 0;
  let new_name;
  let new_selector;
  while (count < 0xfffffffff && new_selector != desired_selector) {
    count++;
    if (count % 10000000 === 0) console.log({ new_name, new_selector, count });
    new_name = `add_${String(Math.random()).slice(3)}(uint256,uint256)`;
    new_selector = ethers.id(new_name).slice(0, 10);
  }
  console.log({ new_name, new_selector, done: true });
})();
