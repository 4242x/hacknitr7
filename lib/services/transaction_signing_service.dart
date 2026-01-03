/// Service for signing transactions using MetaMask via WebView
/// This creates a simple HTML page that uses Web3.js to interact with MetaMask
class TransactionSigningService {
  // Generate HTML page for MetaMask transaction signing
  static String generateTransactionHTML({
    required String contractAddress,
    required String recipientAddress,
    required String tokenId,
    required String locationName,
    required int chainId,
  }) {
    
    // Encode parameters manually (simplified - in production use proper ABI encoding)
    // For now, we'll use a simpler approach with Web3.js
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Transaction</title>
    <script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        button {
            background: #f6851b;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            margin-top: 10px;
        }
        button:hover {
            background: #e6741a;
        }
        button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .status {
            margin-top: 20px;
            padding: 10px;
            border-radius: 5px;
        }
        .success {
            background: #d4edda;
            color: #155724;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
        }
        .info {
            background: #d1ecf1;
            color: #0c5460;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Sign NFT Mint Transaction</h2>
        <p><strong>Recipient:</strong> $recipientAddress</p>
        <p><strong>Token ID:</strong> $tokenId</p>
        <p><strong>Location:</strong> $locationName</p>
        <p><strong>Network:</strong> Polygon Amoy Testnet</p>
        
        <div id="status" class="status info">
            Click the button below to connect MetaMask and sign the transaction.
        </div>
        
        <button id="signBtn" onclick="signTransaction()">Sign Transaction with MetaMask</button>
        <button id="closeBtn" onclick="closeWindow()" style="background: #6c757d; margin-top: 10px;">Close</button>
    </div>

    <script>
        let web3;
        const contractAddress = '$contractAddress';
        const chainId = $chainId;
        
        // Initialize Web3
        async function initWeb3() {
            if (typeof window.ethereum !== 'undefined') {
                web3 = new Web3(window.ethereum);
                try {
                    // Request account access
                    await window.ethereum.request({ method: 'eth_requestAccounts' });
                    return true;
                } catch (error) {
                    showStatus('Error connecting to MetaMask: ' + error.message, 'error');
                    return false;
                }
            } else {
                showStatus('MetaMask is not installed. Please install MetaMask to continue.', 'error');
                return false;
            }
        }
        
        async function signTransaction() {
            const btn = document.getElementById('signBtn');
            btn.disabled = true;
            showStatus('Connecting to MetaMask...', 'info');
            
            if (!web3) {
                const connected = await initWeb3();
                if (!connected) {
                    btn.disabled = false;
                    return;
                }
            }
            
            try {
                // Check if on correct network
                const currentChainId = await window.ethereum.request({ method: 'eth_chainId' });
                const targetChainId = '0x' + chainId.toString(16);
                
                if (currentChainId !== targetChainId) {
                    showStatus('Please switch to Polygon Amoy Testnet in MetaMask', 'error');
                    btn.disabled = false;
                    return;
                }
                
                showStatus('Preparing transaction...', 'info');
                
                // Get accounts
                const accounts = await web3.eth.getAccounts();
                const fromAddress = accounts[0];
                
                // Prepare contract function call
                const contractABI = [{
                    "inputs": [
                        {"internalType": "address", "name": "to", "type": "address"},
                        {"internalType": "uint256", "name": "tokenId", "type": "uint256"},
                        {"internalType": "string", "name": "locationName", "type": "string"}
                    ],
                    "name": "mint",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                }];
                
                const contract = new web3.eth.Contract(contractABI, contractAddress);
                
                // Estimate gas
                const gasEstimate = await contract.methods.mint(
                    '$recipientAddress',
                    '$tokenId',
                    '$locationName'
                ).estimateGas({ from: fromAddress });
                
                // Send transaction
                showStatus('Please confirm the transaction in MetaMask...', 'info');
                
                const tx = await contract.methods.mint(
                    '$recipientAddress',
                    '$tokenId',
                    '$locationName'
                ).send({
                    from: fromAddress,
                    gas: Math.floor(gasEstimate * 1.2), // Add 20% buffer
                });
                
                // Transaction successful
                showStatus('Transaction successful! Hash: ' + tx.transactionHash, 'success');
                
                // Send result back to Flutter
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('transactionSuccess', {
                        success: true,
                        transactionHash: tx.transactionHash,
                        tokenId: '$tokenId',
                        recipient: '$recipientAddress'
                    });
                } else {
                    // Fallback: show result
                    setTimeout(() => {
                        alert('Transaction Hash: ' + tx.transactionHash + '\\n\\nPlease copy this and return to the app.');
                    }, 1000);
                }
                
            } catch (error) {
                showStatus('Transaction failed: ' + error.message, 'error');
                btn.disabled = false;
                
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('transactionError', {
                        success: false,
                        error: error.message
                    });
                }
            }
        }
        
        function showStatus(message, type) {
            const statusDiv = document.getElementById('status');
            statusDiv.textContent = message;
            statusDiv.className = 'status ' + type;
        }
        
        function closeWindow() {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('closeWindow');
            } else {
                window.close();
            }
        }
        
        // Auto-init on load
        window.addEventListener('load', () => {
            initWeb3();
        });
    </script>
</body>
</html>
''';
  }
}

