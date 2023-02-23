const axios = require("axios");
const ethers = require("ethers");
const { SQS } = require("aws-sdk");
const LendingManagerABI = require('./LenderManager.json');

const ENDPOINT_ADDRESS = "https://api.hyperspace.node.glif.io/rpc/v1";

async function sendMessage(id, response) {
  const sqs = new SQS({ region: "us-west-2" });
  const queueUrl = "https://sqs.us-west-2.amazonaws.com/130922966848/contract-event-listener-queue";
  const params = {
    MessageBody: JSON.stringify({ id: id, address: response }),
    QueueUrl: queueUrl,
  };
  const result = await sqs.sendMessage(params).promise();
  console.log(result);
}

async function main() {
  const LENDER_MANAGER_ADDRESS = "0x3f06D24C8F7F6E1eE99Db84A03b3563C89345A05";
  const PROVIDER = new ethers.providers.JsonRpcProvider(ENDPOINT_ADDRESS);
  const LenderManager = new ethers.Contract(LENDER_MANAGER_ADDRESS, LendingManagerABI, PROVIDER);
  const lenderManager = LenderManager.attach(LENDER_MANAGER_ADDRESS);
  const processedIds = new Set();

  lenderManager.on(
    "CheckReputation",
    async function (id, response) {
      id = parseInt(id._hex, 16);
      console.log("**** EVENT RECEIVED ****");
      console.log(JSON.stringify({ id: id, address: response }))

      // check if the id has already been processed
      if (processedIds.has(id)) {
        return;
      }

      // add the id to the set of processed ids
      processedIds.add(id);
      console.log("PROCESSED IDS SET");
      console.log(processedIds);

      setTimeout(function() {
        for (const currentId of processedIds) {
          console.log("CURRENT ID");
          console.log(currentId);
          console.log(response);
          // Not sure the line below is good enough on response, might not match in prod
          sendMessage(currentId, response);
          processedIds.delete(currentId);
        }
      }, 5000);
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});