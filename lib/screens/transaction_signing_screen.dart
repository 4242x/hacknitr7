import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/metamask_deep_link_service.dart';
import '../services/blockchain_service.dart';
import '../services/transaction_signing_service.dart';
import '../services/backend_mint_service.dart';
import '../providers/chain_provider.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class TransactionSigningScreen extends StatefulWidget {
  final String tokenId;
  final String recipientAddress;
  final String locationName;

  const TransactionSigningScreen({
    super.key,
    required this.tokenId,
    required this.recipientAddress,
    required this.locationName,
  });

  @override
  State<TransactionSigningScreen> createState() =>
      _TransactionSigningScreenState();
}

class _TransactionSigningScreenState extends State<TransactionSigningScreen> {
  bool _isLoading = false;
  String? _transactionHash;
  String? _error;
  bool _metamaskInstalled = false;

  @override
  void initState() {
    super.initState();
    _checkMetaMaskInstallation();
  }

  Future<void> _checkMetaMaskInstallation() async {
    final installed = await MetaMaskDeepLinkService.isMetaMaskInstalled();
    setState(() {
      _metamaskInstalled = installed;
    });
  }

  Future<void> _openMetaMaskTransaction() async {
    final chainProvider = context.read<ChainProvider>();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Generate the transaction HTML
      final html = TransactionSigningService.generateTransactionHTML(
        contractAddress: BlockchainService.getContractAddress(chainProvider),
        recipientAddress: widget.recipientAddress,
        tokenId: widget.tokenId,
        locationName: widget.locationName,
        chainId: chainProvider.chainId,
      );

      // Open in MetaMask's DApp browser (which has window.ethereum)
      final success = await MetaMaskDeepLinkService.openInMetaMaskBrowser(
        htmlContent: html,
      );

      if (success) {
        // MetaMask browser opened successfully
        if (mounted) {
          _showMetaMaskBrowserInstructions();
        }
      } else {
        setState(() {
          _error =
              'Could not open MetaMask browser. Please ensure MetaMask is installed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showMetaMaskBrowserInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white10),
        ),
        title: Row(
          children: [
            Icon(Icons.web, color: AppTheme.accentCyan),
            SizedBox(width: 12),
            Text(
              'MetaMask Browser Opened',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The transaction page should now be open in MetaMask\'s built-in browser.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Steps:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Review the transaction details',
              style: TextStyle(color: Colors.white60),
            ),
            Text(
              '2. Click "Sign Transaction with MetaMask"',
              style: TextStyle(color: Colors.white60),
            ),
            Text(
              '3. Confirm in MetaMask popup',
              style: TextStyle(color: Colors.white60),
            ),
            Text(
              '4. Return to this app',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _useBackendMinting() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check backend health first
      final isHealthy = await BackendMintService.checkHealth();
      if (!isHealthy) {
        throw Exception(
          'Cannot connect to backend. Make sure the server is running on http://192.168.0.242:3000',
        );
      }

      // Mint NFT via backend
      final result = await BackendMintService.mintNFT(
        recipientAddress: widget.recipientAddress,
        tokenId: widget.tokenId,
        locationName: widget.locationName,
      );

      if (result['success'] == true) {
        setState(() {
          _isLoading = false;
          _transactionHash = result['transactionHash'];
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NFT minted successfully!\nBlock: ${result['blockNumber']}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Minting failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      appBar: AppBar(
        title: const Text(
          'Sign Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (_transactionHash != null)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
              onPressed: () {
                Navigator.pop(context, {
                  'success': true,
                  'transactionHash': _transactionHash,
                  'tokenId': widget.tokenId,
                });
              },
            ),
        ],
      ),
      body: _transactionHash != null
          ? _buildSuccessView()
          : _buildTransactionView(),
    );
  }

  Widget _buildTransactionView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Details Card
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.surfaceGlass, AppTheme.surfaceDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppTheme.accentCyan,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Transaction Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailRow('Action', 'Mint NFT'),
                _buildDetailRow('Location', widget.locationName),
                _buildDetailRow(
                  'Token ID',
                  widget.tokenId.length > 8
                      ? '#${widget.tokenId.substring(0, 8)}...'
                      : '#${widget.tokenId}',
                ),
                _buildDetailRow(
                  'Recipient',
                  widget.recipientAddress.length > 18
                      ? '${widget.recipientAddress.substring(0, 10)}...${widget.recipientAddress.substring(widget.recipientAddress.length - 8)}'
                      : widget.recipientAddress,
                ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // MetaMask Status
          if (!_metamaskInstalled)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'MetaMask app not detected. Install it or use simulated transaction.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          if (_error != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 32),

          // Action Buttons - Backend minting (Real blockchain!)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _useBackendMinting,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.cloud_upload),
              label: Text(
                _isLoading ? 'Minting NFT...' : 'Mint NFT (Real Blockchain)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          if (_metamaskInstalled) ...[
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openMetaMaskTransaction,
                icon: Icon(Icons.account_balance_wallet, color: Colors.white70),
                label: Text(
                  'Try MetaMask (Limited Support)',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: 24),

          Center(
            child: Text(
              _metamaskInstalled
                  ? 'MetaMask deep links don\'t support NFT minting yet'
                  : 'Install MetaMask for future blockchain features',
              style: TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: label == 'Recipient' || label == 'Token ID'
                    ? 'monospace'
                    : null,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 80,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Transaction Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    'Transaction Hash',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _transactionHash!.length > 18
                        ? '${_transactionHash!.substring(0, 10)}...${_transactionHash!.substring(_transactionHash!.length - 8)}'
                        : _transactionHash!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'success': true,
                    'transactionHash': _transactionHash,
                    'tokenId': widget.tokenId,
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Return to App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
