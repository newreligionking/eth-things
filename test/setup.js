const { config } = require("dotenv");
const path = require("path");

config({
  path: path.join(__dirname, "../.env.local"),
});
