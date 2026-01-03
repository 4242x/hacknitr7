import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

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
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('Connect Wallet'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: size.width * 0.06,
                        ),
                        SizedBox(width: size.width * 0.03),
                        Text(
                          'Connect Your Wallet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'To claim NFTs on the blockchain, you need to connect a Web3 wallet. Enter your wallet address below.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      'Supported: MetaMask, Trust Wallet, Coinbase Wallet, etc.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            
            // Wallet Address Input
            Text(
              'Wallet Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: size.height * 0.01),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: '0x...',
                labelText: 'Enter your wallet address',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Paste from clipboard',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            SizedBox(height: size.height * 0.02),
            
            // Instructions
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to get your wallet address:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    _buildInstruction(
                      context,
                      size,
                      '1. Open MetaMask (or your wallet app)',
                    ),
                    _buildInstruction(
                      context,
                      size,
                      '2. Tap on your account name',
                    ),
                    _buildInstruction(
                      context,
                      size,
                      '3. Copy your address',
                    ),
                    _buildInstruction(
                      context,
                      size,
                      '4. Paste it here',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            
            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _connectWallet,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                ),
                child: _isValidating
                    ? SizedBox(
                        height: size.height * 0.02,
                        width: size.height * 0.02,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Connect Wallet',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            if (walletProvider.isConnected) ...[
              SizedBox(height: size.height * 0.02),
              Divider(),
              SizedBox(height: size.height * 0.02),
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Wallet Connected'),
                  subtitle: Text(walletProvider.displayAddress),
                  trailing: TextButton(
                    onPressed: () async {
                      await walletProvider.disconnectWallet();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Disconnect'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, Size size, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.008),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            size: size.width * 0.04,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}




