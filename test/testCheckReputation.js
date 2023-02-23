const axios = require("axios");
const ethers = require("ethers");
const fs = require('fs');
const LendingManagerABI = require('./LenderManager.json');

const ENDPOINT_ADDRESS = "https://api.hyperspace.node.glif.io/rpc/v1";

async function callRpc(method, params) {
  const res = await axios.post(ENDPOINT_ADDRESS, {
    jsonrpc: "2.0",
    method: method,
    params: params,
    id: 1,
  });
  return res.data;
}

async function main(address) {
  try {
    const LENDER_MANAGER_ADDRESS = "0x3f06D24C8F7F6E1eE99Db84A03b3563C89345A05";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const WALLET = new ethers.Wallet(PRIVATE_KEY);
    const PROVIDER = new ethers.providers.JsonRpcProvider(ENDPOINT_ADDRESS);
    const SIGNER = WALLET.connect(PROVIDER);
    const LenderManager = new ethers.Contract(LENDER_MANAGER_ADDRESS, LendingManagerABI, SIGNER);
    const lenderManager = LenderManager.attach(LENDER_MANAGER_ADDRESS);
    var priorityFee = await callRpc("eth_maxPriorityFeePerGas");
    await lenderManager.checkReputation(address, {
      maxPriorityFeePerGas: priorityFee.result,
    });
  } catch (error) {
    console.log(error);
  }
}

// In Lambda, this address will be passed via the event listener
main("0x73CF998AF5dF38c849A58fc3d40142e6574c27AC");