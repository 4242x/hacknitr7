import 'package:flutter/foundation.dart';
import '../models/nft_model.dart';
import '../services/nft_service.dart';

class NFTProvider with ChangeNotifier {
  List<NFTModel> _availableNFTs = [];
  List<NFTModel> _claimedNFTs = [];
  bool _isLoading = false;
  String? _error;

  List<NFTModel> get availableNFTs => _availableNFTs;
  List<NFTModel> get claimedNFTs => _claimedNFTs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAvailableNFTs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableNFTs = await NFTService.getAllAvailableNFTs();
      _error = null;
    } catch (e) {
      _error = 'Failed to load NFTs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClaimedNFTs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _claimedNFTs = await NFTService.getClaimedNFTs();
      _error = null;
    } catch (e) {
      _error = 'Failed to load claimed NFTs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> claimNFT(String tokenId, double userLat, double userLon, String? walletAddress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if wallet is connected
      if (walletAddress == null || walletAddress.isEmpty) {
        _error = 'Please connect your wallet to claim NFTs';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Find the location for this NFT
      var allNFTs = await NFTService.getAllAvailableNFTs();
      var nft = allNFTs.firstWhere((n) => n.tokenId == tokenId);
      
      if (nft.location == null) {
        _error = 'Location not found for this NFT';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if user is within range
      bool canClaim = await NFTService.canClaimNFT(
        userLat,
        userLon,
        nft.location!,
      );

      if (!canClaim) {
        _error = 'You are not close enough to claim this NFT. Please visit the location.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validation passed - transaction signing will happen in UI
      // Return true to indicate validation passed, actual minting happens after signing
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error claiming NFT: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


