/* eslint-disable */
import web3 from './web3';

const address = '0xffB44EEe0Abb67416f1623F9e8453396379a12c0'; // Your deployed contract's address goes here
// Example:
// const address = '0x09r80cnasjfaks93m9v2';

const abi = [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "title",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "description",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "durationInDays",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "targetAmount",
				"type": "uint256"
			}
		],
		"name": "addRequest",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "requestor",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "requestName",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "requestDesc",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "goalAmount",
				"type": "uint256"
			}
		],
		"name": "RequestAdded",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "returnAllRequests",
		"outputs": [
			{
				"internalType": "contract Request[]",
				"name": "",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]; // Your ABI goes here (Crowdfunding contract)
// Example:
// const abi = [
//     {
//         "anonymous": false,
//         "inputs": [
//             {
//                 "indexed": false,
//                 "name": "contractAddress",
//                 "type": "address"
//             }
//         ],
//         "name": "ProjectStarted",
//         "type": "event"
//     }
// ];

const instance = new web3.eth.Contract(abi, address);

export default instance;
