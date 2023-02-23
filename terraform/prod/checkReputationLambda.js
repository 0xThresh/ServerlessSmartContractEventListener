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

// async function getData(apiUrl, params) {
//   try {
//       const response = await axios.get(apiUrl + params);
//       return response.data['miners'];
//   } catch (error) {
//       return error.message;
//   }
// }

// async function determineIfMinerIsReputable(jsonData) {
//   var minerIsReputable = false;
//   var minerReputation = jsonData[0].score;
//   var minerReachable = jsonData[0].reachability;

//   if (minerReputation > 95 && minerReachable === 'reachable') {
//       minerIsReputable = true;
//       return minerIsReputable;
//   }
//   else {
//       return minerIsReputable;
//   }
// }

async function main(id, address) {
	  try {
		      const LENDER_MANAGER_ADDRESS = process.env.CONTRACT_ADDRESS;
		      const PRIVATE_KEY = process.env.PRIVATE_KEY;
		      const WALLET = new ethers.Wallet(PRIVATE_KEY);
		      const PROVIDER = new ethers.providers.JsonRpcProvider(ENDPOINT_ADDRESS);
		      const SIGNER = WALLET.connect(PROVIDER);
		      const LenderManager = new ethers.Contract(LENDER_MANAGER_ADDRESS, LendingManagerABI, SIGNER);
		      const lenderManager = LenderManager.attach(LENDER_MANAGER_ADDRESS);
		      console.log("GETTING GAS PRICE");
		      var priorityFee = await callRpc("eth_maxPriorityFeePerGas");
		      // The line below would wait for the API check to complete, and use the data from that 
		      console.log("SENDING REPUTATION TXN");
              await lenderManager.receiveReputationScore(id, 2, {
	            gasLimit: 1000000000,
	            maxPriorityFeePerGas: priorityFee.result,
	          });
              console.log("REPUTATION INFO SENT");
		    } catch (error) {
			        console.log(error);
			      }
}

exports.handler = (event) => {
	var message = event.Records[0].body;
	message = JSON.parse(message);
	var id = message.id;
	console.log(`ID: ${id}`);
	var address = message.address;
	console.log(`ADDRESS: ${address}`);
	main(id, address);
};
