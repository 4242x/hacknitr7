import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for minting NFTs via backend API
class BackendMintService {
  // For local development:
  // - Android Emulator: use 'http://10.0.2.2:3000'
  // - iOS Simulator: use 'http://localhost:3000'
  // - Physical Device: use your computer's IP (e.g., 'http://192.168.1.100:3000')
  static const String baseUrl =
      'http://192.168.0.242:3000'; // Your computer's IP

  /// Mint NFT via backend
  static Future<Map<String, dynamic>> mintNFT({
    required String recipientAddress,
    required String tokenId,
    required String locationName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/mint-nft'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'recipientAddress': recipientAddress,
              'tokenId': tokenId,
              'locationName': locationName,
            }),
          )
          .timeout(
            const Duration(seconds: 60), // Minting can take time
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to mint NFT');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check if backend is reachable
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
