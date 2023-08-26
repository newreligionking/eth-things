const fs = require("fs");
const path = require("path");
const solc = require("solc");

let input = {
  language: "Solidity",
  sources: {},
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const contracts = path.join(__dirname, "../contracts");

fs.readdirSync(contracts)
  .filter((a) => a.endsWith(".sol"))
  .forEach((contract) => {
    console.log(contract);
    const source = fs.readFileSync(path.join(contracts, contract));
    input.sources[contract] = { content: source.toString() };
  });

const output = JSON.parse(solc.compile(JSON.stringify(input)));

module.exports = { output };
/** console.log(output);
{
  contracts: {
    'CommitReveal.sol': { CommitReveal: [Object] },
    'Timelocked.sol': { Timelocked: [Object] }
  },
  sources: {
    'CommitReveal.sol': { id: 0 },
    'SafeMath.sol': { id: 1 },
    'Timelocked.sol': { id: 2 }
  }
}
*/
