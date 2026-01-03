import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/transaction_signing_service.dart';
import '../services/blockchain_service.dart';

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
  State<TransactionSigningScreen> createState() => _TransactionSigningScreenState();
}

class _TransactionSigningScreenState extends State<TransactionSigningScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  String? _transactionHash;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Generate HTML for transaction signing
    final html = TransactionSigningService.generateTransactionHTML(
      contractAddress: BlockchainService.nftContractAddress,
      recipientAddress: widget.recipientAddress,
      tokenId: widget.tokenId,
      locationName: widget.locationName,
      chainId: 80002, // Polygon Amoy
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Transaction'),
        actions: [
          if (_transactionHash != null)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Loading transaction...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(size.width * 0.05),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: size.width * 0.2,
                      color: Colors.red,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.03),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                        _initializeWebView();
                      },
                      child: const Text('Retry'),
                    ),
                    SizedBox(height: size.height * 0.01),
                    TextButton(
                      onPressed: () => Navigator.pop(context, {'success': false}),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _transactionHash != null
          ? Container(
              padding: EdgeInsets.all(size.width * 0.04),
              color: Colors.green.withValues(alpha: 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Text(
                          'Transaction successful!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Hash: ${_transactionHash!.substring(0, 10)}...${_transactionHash!.substring(_transactionHash!.length - 8)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: size.width * 0.03,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
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
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

