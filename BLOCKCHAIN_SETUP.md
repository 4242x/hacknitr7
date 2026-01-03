# Blockchain Integration Guide

This guide will help you connect your Flutter app to Polygon Amoy Testnet for real NFT minting.

## Prerequisites

1. **MetaMask Wallet** (or any Web3 wallet)
2. **Polygon Amoy Testnet MATIC** (free test tokens)
3. **Deployed NFT Smart Contract** on Polygon Amoy

## Step 1: Add Polygon Amoy Network to MetaMask

1. Open MetaMask
2. Click on the network dropdown (top of MetaMask)
3. Click "Add Network" or "Add a network manually"
4. Enter the following details:
   - **Network Name**: Polygon Amoy Testnet
   - **RPC URL**: `https://rpc-amoy.polygon.technology`
   - **Chain ID**: 80002
   - **Currency Symbol**: MATIC
   - **Block Explorer URL**: `https://amoy.polygonscan.com`
5. Click "Save"

## Step 2: Get Testnet MATIC

1. Make sure MetaMask is connected to Polygon Amoy Testnet
2. Copy your MetaMask wallet address
3. Visit [Polygon Faucet](https://faucet.polygon.technology/)
4. Select "Amoy" testnet
5. Enter your wallet address
6. Request test MATIC tokens (free)
7. Wait a few minutes for the tokens to arrive

## Step 3: Deploy NFT Smart Contract on Polygon Amoy

### Using Remix IDE (Recommended)

1. **Open Remix IDE**: Go to [https://remix.ethereum.org/](https://remix.ethereum.org/)

2. **Create Contract File**:
   - In the left sidebar, click "File Explorer"
   - Click the "+" icon to create a new file
   - Name it `LocationNFT.sol`
   - Paste the contract code from below

3. **Install OpenZeppelin Contracts**:
   - In Remix, go to "File Explorer"
   - Click "Create new folder" and name it `@openzeppelin`
   - Inside that folder, create another folder named `contracts`
   - Create a file `token/ERC721/ERC721.sol` and copy the OpenZeppelin ERC721 contract
   - Create a file `access/Ownable.sol` and copy the OpenZeppelin Ownable contract
   - **OR** use Remix's GitHub import: In the contract file, the import statement should work if you have the OpenZeppelin package installed
   - **Easier Option**: Use Remix's "Solidity Compiler" tab, click "Advanced Configurations", and enable "Auto compile" - Remix will automatically fetch dependencies

4. **Compile the Contract**:
   - Go to the "Solidity Compiler" tab (icon looks like a checkmark)
   - Select compiler version: `0.8.20` or higher
   - Click "Compile LocationNFT.sol"
   - Make sure there are no errors (green checkmark appears)

5. **Connect MetaMask to Remix**:
   - Go to the "Deploy & Run Transactions" tab (icon looks like a rocket)
   - In the "Environment" dropdown, select **"Injected Provider - MetaMask"**
   - MetaMask will pop up asking you to connect - click "Next" and "Connect"
   - **Important**: Make sure MetaMask is connected to "Polygon Amoy Testnet" (check the network dropdown in MetaMask)

6. **Deploy the Contract**:
   - In the "Deploy & Run Transactions" tab
   - Under "Contract", select "LocationNFT - contracts/LocationNFT.sol"
   - Click the orange "Deploy" button
   - MetaMask will pop up with a transaction - review it and click "Confirm"
   - Wait for the transaction to be confirmed (usually takes 10-30 seconds)

7. **Copy the Contract Address**:
   - After deployment, you'll see your contract in the "Deployed Contracts" section
   - Click the copy icon next to the contract address
   - **Save this address** - you'll need it for your Flutter app!

## Step 4: Update Contract Address in Flutter App

1. Open `lib/services/blockchain_service.dart`
2. Replace `nftContractAddress` with your deployed contract address
3. Update the ABI if you modified the contract

## Step 5: Get Contract ABI from Remix

1. In Remix IDE, go to "Solidity Compiler" tab
2. After compiling, click on "ABI" button (next to the contract name)
3. Copy the entire ABI JSON
4. This will be used to update `contractABI` in `blockchain_service.dart`

## Step 6: Connect Wallet in App

The app now supports wallet connection. Users can:
1. Tap "Connect Wallet" button on the home screen
2. Enter their wallet address manually
3. The address is saved for future use
4. When claiming NFTs, the wallet address will be used

**Note**: For full Web3 integration with transaction signing, you'll need to integrate:
- **WalletConnect** for mobile wallet connections
- **MetaMask SDK** for browser-based wallets
- Or use a service like **Magic.link** or **Web3Auth** for seamless wallet management

## Step 7: Update the Code

1. Open `lib/services/blockchain_service.dart`
2. Replace `nftContractAddress` (line 12) with your deployed contract address from Remix
3. Update `contractABI` (line 15) with your contract's ABI from Remix (see Step 5)
4. The service is ready to interact with your contract

## Step 8: Test the Integration

1. Run the Flutter app
2. Connect your wallet (enter your wallet address)
3. Visit a location in Kolkata
4. Claim an NFT
5. Check your wallet on [Polygonscan Amoy](https://amoy.polygonscan.com/) to see your NFT

## Current Implementation Status

✅ **Wallet Address Storage**: Users can connect and save their wallet address  
✅ **Wallet Manager in Settings**: Full wallet management UI with connect/disconnect  
✅ **Collection Screen Integration**: Shows connect wallet prompt when not connected  
✅ **Blockchain Service**: Ready to interact with smart contracts  
✅ **NFT Minting Logic**: Integrated with location-based claiming  
✅ **Real Wallet Address Usage**: NFT claiming now uses connected wallet address  
⚠️ **Transaction Signing**: Currently uses simulated transactions (see below for real integration)

## Wallet Management Features

The app now includes comprehensive wallet management:

1. **Settings Screen - Wallet Manager**:
   - View connected wallet address
   - Copy wallet address to clipboard
   - Disconnect wallet
   - Connect wallet button when not connected

2. **Collection Screen**:
   - Shows "Connect Wallet" prompt when user is not logged in
   - Displays wallet address in app bar when connected
   - Only shows collection when wallet is connected

3. **NFT Claiming**:
   - Requires wallet connection before claiming
   - Uses real wallet address for NFT minting
   - Prompts user to connect wallet if not connected

## Next Steps for Full Blockchain Integration

The app is currently using **simulated transactions** for NFT minting. To enable **real blockchain transactions** with transaction signing, you have several options:

### Option 1: WalletConnect Integration (Recommended for Mobile)

1. **Add WalletConnect Dependencies**:
   ```yaml
   dependencies:
     wallet_connect_flutter: ^2.0.0
     # or
     walletconnect_flutter: ^1.0.0
   ```

2. **Update WalletProvider** to use WalletConnect:
   - Initialize WalletConnect session
   - Handle connection requests
   - Sign transactions through WalletConnect

3. **Update Blockchain Service**:
   - Replace `mintNFTSimulated` with real transaction signing
   - Use WalletConnect to sign transactions
   - Handle transaction confirmations

### Option 2: MetaMask Deep Links (Simpler, Mobile Only)

1. **Add URL Launcher**:
   ```yaml
   dependencies:
     url_launcher: ^6.2.0
   ```

2. **Create Transaction Signing Service**:
   - Build transaction data
   - Open MetaMask via deep link
   - Handle transaction response

### Option 3: Backend Service (Most Secure)

1. **Create Backend API**:
   - Handle transaction signing server-side
   - Use contract owner's private key (securely stored)
   - Users submit claims, backend mints NFTs

2. **Update App**:
   - Send claim requests to backend
   - Backend verifies location and mints NFT
   - App polls for transaction status

### Current Implementation Note

The app currently uses `BlockchainService.mintNFTSimulated()` which simulates the minting process. To enable real blockchain transactions:

1. Replace the call in `lib/providers/nft_provider.dart` (line ~89):
   ```dart
   // Current (simulated):
   var result = await BlockchainService.mintNFTSimulated(tokenId, ownerAddress);
   
   // Real blockchain (requires transaction signing):
   var result = await BlockchainService.mintNFT(
     tokenId,
     ownerAddress,
     privateKey, // Get from secure storage or WalletConnect
   );
   ```

2. **Important**: Real transactions require:
   - User's private key (never store in app!)
   - Transaction signing (WalletConnect or similar)
   - Gas fees payment
   - Network confirmation

3. **Security Best Practices**:
   - Never store private keys in the app
   - Use WalletConnect or similar for signing
   - Always verify transactions on blockchain
   - Handle transaction failures gracefully

## Smart Contract Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LocationNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => string) private _locationNames;
    
    constructor() ERC721("Kolkata Location NFT", "KLNFT") Ownable(msg.sender) {}
    
    // Helper function to check if token exists (replaces deprecated _exists)
    function _tokenExists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    function mint(address to, uint256 tokenId, string memory locationName) public onlyOwner {
        require(!_tokenExists(tokenId), "Token already exists");
        _safeMint(to, tokenId);
        _locationNames[tokenId] = locationName;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_tokenExists(tokenId), "Token does not exist");
        return _tokenURIs[tokenId];
    }
    
    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        require(_tokenExists(tokenId), "Token does not exist");
        _tokenURIs[tokenId] = uri;
    }
    
    function locationName(uint256 tokenId) public view returns (string memory) {
        require(_tokenExists(tokenId), "Token does not exist");
        return _locationNames[tokenId];
    }
}
```

## Important Notes

- **Testnet Only**: This setup is for Polygon Amoy testnet (free)
- **Gas Fees**: Testnet transactions are free (using test MATIC)
- **Contract Verification**: Verify your contract on Polygonscan for transparency
- **Security**: Never commit private keys or mnemonics to version control
- **EVM Compatible**: Polygon is fully EVM-compatible, so your contracts work without modification

## Troubleshooting

- **Transaction Failed**: Check you have enough test MATIC tokens (get from faucet)
- **MetaMask Not Connecting**: Make sure you selected "Injected Provider - MetaMask" in Remix
- **Wrong Network**: Ensure MetaMask is connected to "Polygon Amoy Testnet" (Chain ID: 80002)
- **Contract Not Found**: Verify contract address is correct and copied properly
- **Compilation Errors**: Make sure you're using Solidity compiler version 0.8.20 or compatible
- **Import Errors**: If OpenZeppelin imports fail, use Remix's GitHub import feature or manually add the contracts

## Next Steps

1. Deploy your contract
2. Update the contract address in the code
3. Test minting an NFT
4. Verify on Polygonscan Amoy
5. Consider adding IPFS for metadata storage

