import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BlockchainChain {
  shardeum,
  polygon,
}

class ChainProvider with ChangeNotifier {
  BlockchainChain _currentChain = BlockchainChain.shardeum;
  bool _isLoading = false;

  BlockchainChain get currentChain => _currentChain;
  bool get isLoading => _isLoading;

  // Chain details
  String get chainName {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return 'Shardeum Testnet';
      case BlockchainChain.polygon:
        return 'Polygon Amoy';
    }
  }

  String get rpcUrl {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return 'https://api-mezame.shardeum.org';
      case BlockchainChain.polygon:
        return 'https://rpc-amoy.polygon.technology';
    }
  }

  int get chainId {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return 8082;
      case BlockchainChain.polygon:
        return 80002;
    }
  }

  String get currencySymbol {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return 'SHM';
      case BlockchainChain.polygon:
        return 'MATIC';
    }
  }

  String get explorerUrl {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return 'https://explorer-mezame.shardeum.org';
      case BlockchainChain.polygon:
        return 'https://amoy.polygonscan.com';
    }
  }

  // Contract addresses (you'll need to deploy on both chains)
  String get contractAddress {
    switch (_currentChain) {
      case BlockchainChain.shardeum:
        return '0x0000000000000000000000000000000000000000'; // Update with Shardeum contract address
      case BlockchainChain.polygon:
        return '0x558DBA74dFF9824B0Cd40E3fd21b278ABFfC7a4F'; // Current Polygon contract
    }
  }

  ChainProvider() {
    _loadChain();
  }

  Future<void> _loadChain() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedChain = prefs.getString('selected_chain');
      if (savedChain != null) {
        _currentChain = BlockchainChain.values.firstWhere(
          (chain) => chain.toString() == savedChain,
          orElse: () => BlockchainChain.shardeum,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> switchChain(BlockchainChain chain) async {
    if (_currentChain == chain) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentChain = chain;

      // Save chain preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_chain', chain.toString());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}

