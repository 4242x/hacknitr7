import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/transaction_signing_service.dart';
import '../services/blockchain_service.dart';
import '../theme/app_theme.dart';

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
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            Container(
              color: AppTheme.deepBackground,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryPurple),
                    SizedBox(height: 20),
                    Text(
                      'Preparing secure environment...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Container(
              color: AppTheme.deepBackground,
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Connection Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                        _initializeWebView();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                      ),
                      child: const Text('Retry'),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, {'success': false}),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _transactionHash != null
          ? Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transaction successful!',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hash:',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          '${_transactionHash!.substring(0, 10)}...${_transactionHash!.substring(_transactionHash!.length - 8)}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                        backgroundColor: AppTheme.primaryPurple,
                      ),
                      child: const Text('Return to App'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
