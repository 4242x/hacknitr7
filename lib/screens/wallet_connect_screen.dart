import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  bool _isValidAddress(String address) {
    return address.startsWith('0x') && 
           address.length == 42 && 
           RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }

  Future<void> _connectWallet() async {
    final address = _addressController.text.trim();
    
    if (!_isValidAddress(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Ethereum address (0x...)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isValidating = true);
    
    final walletProvider = context.read<WalletProvider>();
    final success = await walletProvider.connectWallet(address);
    
    setState(() => _isValidating = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet connected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && walletProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _addressController.text = clipboardData!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      appBar: AppBar(
        title: const Text('Connect Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
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
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.accentCyan,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Link Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'To claim NFTs on the blockchain, you need to connect a Web3 wallet. Enter your wallet address below.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // Wallet Address Input
            Text(
              'Wallet Address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _addressController,
              style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: '0x...',
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppTheme.surfaceGlass,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.white54),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Paste from clipboard',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primaryPurple),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 32),
            
            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _connectWallet,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: AppTheme.primaryPurple.withOpacity(0.5),
                ),
                child: _isValidating
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Unlock Features',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            SizedBox(height: 20),
            Center(
              child: Text(
                'Supported: MetaMask, Trust Wallet, etc.',
                 style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),

            if (walletProvider.isConnected) ...[
              SizedBox(height: 40),
              Container(
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.green.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.green.withOpacity(0.3)),
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.check_circle, color: Colors.greenAccent),
                     SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Connected', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                           Text(walletProvider.displayAddress, style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'monospace')),
                         ],
                       ),
                     ),
                     IconButton(
                       icon: Icon(Icons.logout, color: Colors.white38),
                       onPressed: () async {
                         await walletProvider.disconnectWallet();
                         if (mounted) setState((){}); // refresh
                       },
                     ),
                   ],
                 ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
