// Blockchain service - supports multiple chains (Shardeum and Polygon)
// Update the contract address after deploying your NFT contract

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../providers/chain_provider.dart';

class BlockchainService {
  // Get RPC URL from chain provider
  static String getRpcUrl(ChainProvider chainProvider) {
    return chainProvider.rpcUrl;
  }
  
  // Get contract address from chain provider
  static String getContractAddress(ChainProvider chainProvider) {
    return chainProvider.contractAddress;
  }
  
  // Get chain ID from chain provider
  static int getChainId(ChainProvider chainProvider) {
    return chainProvider.chainId;
  }
  
  // Legacy support - Polygon Amoy (for backward compatibility)
  static const String polygonAmoyRpc = 'https://rpc-amoy.polygon.technology';
  static const String polygonContractAddress = '0x558DBA74dFF9824B0Cd40E3fd21b278ABFfC7a4F';
  
  // Shardeum Liberty
  static const String shardeumRpc = 'https://api-mezame.shardeum.org';
  static const String shardeumContractAddress = '0x558DBA74dFF9824B0Cd40E3fd21b278ABFfC7a4F'; // Update with deployed address
  
  // Current contract address (use getContractAddress instead)
  @Deprecated('Use getContractAddress(chainProvider) instead')
  static const String nftContractAddress = polygonContractAddress;
  
  // Contract ABI - Full ABI from deployed contract
  static const String contractABI = '''
 [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "ERC721IncorrectOwner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ERC721InsufficientApproval",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "approver",
				"type": "address"
			}
		],
		"name": "ERC721InvalidApprover",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			}
		],
		"name": "ERC721InvalidOperator",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "ERC721InvalidOwner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			}
		],
		"name": "ERC721InvalidReceiver",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "ERC721InvalidSender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ERC721NonexistentToken",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "locationName",
				"type": "string"
			}
		],
		"name": "mint",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "OwnableInvalidOwner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "OwnableUnauthorizedAccount",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "approved",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "ApprovalForAll",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "setApprovalForAll",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "uri",
				"type": "string"
			}
		],
		"name": "setTokenURI",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "getApproved",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			}
		],
		"name": "isApprovedForAll",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "locationName",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ownerOf",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "tokenURI",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
  ''';

  // Create Web3 client
  static Web3Client getClient(ChainProvider chainProvider) {
    return Web3Client(getRpcUrl(chainProvider), http.Client());
  }
  
  // Legacy method (uses Polygon)
  @Deprecated('Use getClient(chainProvider) instead')
  static Web3Client getClientLegacy() {
    return Web3Client(polygonAmoyRpc, http.Client());
  }

  // Mint NFT on blockchain
  // Note: This requires the user to sign the transaction with their wallet
  // In a mobile app, you'll need to use WalletConnect or similar for signing
  static Future<Map<String, dynamic>> mintNFT(
    String tokenId,
    String recipientAddress,
    String privateKey, // In production, never store private keys in the app!
    ChainProvider chainProvider,
  ) async {
    try {
      final client = getClient(chainProvider);
      final credentials = EthPrivateKey.fromHex(privateKey);
      
      // Get contract
      final contractAddress = getContractAddress(chainProvider);
      final contract = DeployedContract(
        ContractAbi.fromJson(contractABI, 'LocationNFT'),
        EthereumAddress.fromHex(contractAddress),
      );
      
      // Prepare mint function
      final mintFunction = contract.function('mint');
      final tokenIdBigInt = BigInt.parse(tokenId);
      
      // Call mint function
      final transaction = await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: mintFunction,
          parameters: [
            EthereumAddress.fromHex(recipientAddress),
            tokenIdBigInt,
            'Location $tokenId', // Location name
          ],
        ),
        chainId: getChainId(chainProvider),
      );
      
      // Wait for transaction receipt
      final receipt = await client.getTransactionReceipt(transaction);
      
      await client.dispose();
      
      final success = receipt != null && receipt.status == true;
      final blockNumber = receipt != null ? receipt.blockNumber.toString() : '0';
      
      return {
        'success': success,
        'transactionHash': transaction,
        'tokenId': tokenId,
        'contractAddress': getContractAddress(chainProvider),
        'recipient': recipientAddress,
        'blockNumber': blockNumber,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Check if an address owns a specific NFT
  static Future<bool> checkNFTOwnership(
    String tokenId,
    String ownerAddress,
    ChainProvider chainProvider,
  ) async {
    try {
      final client = getClient(chainProvider);
      
      final contractAddress = getContractAddress(chainProvider);
      final contract = DeployedContract(
        ContractAbi.fromJson(contractABI, 'LocationNFT'),
        EthereumAddress.fromHex(contractAddress),
      );
      
      final ownerOfFunction = contract.function('ownerOf');
      final tokenIdBigInt = BigInt.parse(tokenId);
      
      final result = await client.call(
        contract: contract,
        function: ownerOfFunction,
        params: [tokenIdBigInt],
      );
      
      final owner = result[0] as EthereumAddress;
      final expectedOwner = EthereumAddress.fromHex(ownerAddress);
      
      await client.dispose();
      
      return owner.hex == expectedOwner.hex;
    } catch (e) {
      return false;
    }
  }

  // Get NFT metadata from blockchain
  static Future<Map<String, dynamic>?> getNFTMetadata(
    String tokenId,
    ChainProvider chainProvider,
  ) async {
    try {
      final client = getClient(chainProvider);
      
      final contractAddress = getContractAddress(chainProvider);
      final contract = DeployedContract(
        ContractAbi.fromJson(contractABI, 'LocationNFT'),
        EthereumAddress.fromHex(contractAddress),
      );
      
      final tokenURIFunction = contract.function('tokenURI');
      final tokenIdBigInt = BigInt.parse(tokenId);
      
      final result = await client.call(
        contract: contract,
        function: tokenURIFunction,
        params: [tokenIdBigInt],
      );
      
      final tokenURI = result[0] as String;
      
      await client.dispose();
      
      return {
        'tokenId': tokenId,
        'tokenURI': tokenURI,
      };
    } catch (e) {
      return null;
    }
  }

  // Simulated minting (for testing without real contract)
  // Remove this when you have a real contract deployed
  static Future<Map<String, dynamic>> mintNFTSimulated(
    String tokenId,
    String recipientAddress,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'transactionHash': '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      'tokenId': tokenId,
      'contractAddress': nftContractAddress,
      'recipient': recipientAddress,
      'note': 'This is a simulated transaction. Deploy a real contract to enable blockchain minting.',
    };
  }
}
