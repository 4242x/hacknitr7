import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletProvider with ChangeNotifier {
  String? _walletAddress;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;

  String? get walletAddress => _walletAddress;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;

  // Shortened address for display (first 6 + last 4)
  String get displayAddress {
    if (_walletAddress == null) return '';
    if (_walletAddress!.length < 10) return _walletAddress!;
    return '${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}';
  }

  WalletProvider() {
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedAddress = prefs.getString('wallet_address');
      if (savedAddress != null && savedAddress.isNotEmpty) {
        _walletAddress = savedAddress;
        _isConnected = true;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> connectWallet(String address) async {
    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      if (address.isEmpty || !address.startsWith('0x')) {
        _error = 'Invalid wallet address';
        _isConnecting = false;
        notifyListeners();
        return false;
      }

      _walletAddress = address;
      _isConnected = true;
      _error = null;

      // Save wallet address
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallet_address', address);

      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to connect wallet: $e';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectWallet() async {
    _walletAddress = null;
    _isConnected = false;
    _error = null;

    // Clear saved address
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_address');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}




