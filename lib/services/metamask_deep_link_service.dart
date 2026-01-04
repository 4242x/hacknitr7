import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

/// Service for interacting with MetaMask mobile app via deep links
class MetaMaskDeepLinkService {
  /// Opens MetaMask app to sign a transaction
  ///
  /// This uses MetaMask's deep link protocol to open the app with transaction data
  /// Format: https://metamask.app.link/send/[to_address]@[chain_id]?value=[value]&data=[data]
  static Future<bool> sendTransaction({
    required String contractAddress,
    required String fromAddress,
    required String recipientAddress,
    required String tokenId,
    required String locationName,
    required int chainId,
  }) async {
    try {
      // Encode the function call data
      // mint(address to, uint256 tokenId, string locationName)
      final functionData = _encodeMintFunction(
        recipientAddress: recipientAddress,
        tokenId: tokenId,
        locationName: locationName,
      );

      // Build MetaMask deep link
      // Format: https://metamask.app.link/send/[contract_address]@[chain_id]?data=[encoded_data]
      final deepLink = Uri.parse(
        'https://metamask.app.link/send/$contractAddress@$chainId?data=$functionData',
      );

      print('Opening MetaMask with deep link: $deepLink');

      // Try to launch MetaMask
      final canLaunch = await canLaunchUrl(deepLink);
      if (canLaunch) {
        final launched = await launchUrl(
          deepLink,
          mode: LaunchMode.externalApplication,
        );
        return launched;
      } else {
        print('Cannot launch MetaMask deep link');
        return false;
      }
    } catch (e) {
      print('Error opening MetaMask: $e');
      return false;
    }
  }

  /// Opens a URL in MetaMask's DApp browser
  /// The DApp browser has access to window.ethereum for signing transactions
  static Future<bool> openInMetaMaskBrowser({
    required String htmlContent,
  }) async {
    try {
      // Encode HTML as base64 data URL
      final base64Html = base64Encode(utf8.encode(htmlContent));
      final dataUrl = 'data:text/html;base64,$base64Html';

      // MetaMask browser deep link format
      // metamask://browse/[url] or https://metamask.app.link/dapp/[url]

      // For data URLs, we need to use the browse endpoint
      final metamaskBrowserUrl = Uri.parse(
        'https://metamask.app.link/dapp/$dataUrl',
      );

      print('Opening in MetaMask browser: $metamaskBrowserUrl');

      final canLaunch = await canLaunchUrl(metamaskBrowserUrl);
      if (canLaunch) {
        return await launchUrl(
          metamaskBrowserUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      // Try alternative format
      final alternativeUrl = Uri.parse('metamask://browse/$dataUrl');
      if (await canLaunchUrl(alternativeUrl)) {
        return await launchUrl(
          alternativeUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } catch (e) {
      print('Error opening MetaMask browser: $e');
      return false;
    }
  }

  /// Opens a hosted URL in MetaMask's DApp browser
  static Future<bool> openUrlInMetaMaskBrowser(String url) async {
    try {
      // Remove protocol from URL for MetaMask deep link
      final cleanUrl = url.replaceAll(RegExp(r'^https?://'), '');

      final metamaskBrowserUrl = Uri.parse(
        'https://metamask.app.link/dapp/$cleanUrl',
      );

      print('Opening URL in MetaMask browser: $metamaskBrowserUrl');

      return await launchUrl(
        metamaskBrowserUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error opening URL in MetaMask browser: $e');
      return false;
    }
  }

  /// Encodes the mint function call data
  /// Function signature: mint(address,uint256,string)
  static String _encodeMintFunction({
    required String recipientAddress,
    required String tokenId,
    required String locationName,
  }) {
    // Function selector for mint(address,uint256,string)
    // This is the first 4 bytes of keccak256("mint(address,uint256,string)")
    const functionSelector = '0x1249c58b'; // You may need to calculate this

    // For simplicity, we'll use a basic encoding
    // In production, use proper ABI encoding with web3dart

    // Remove '0x' prefix from address if present
    final cleanAddress = recipientAddress.toLowerCase().replaceAll('0x', '');

    // Pad address to 32 bytes (64 hex chars)
    final paddedAddress = cleanAddress.padLeft(64, '0');

    // Convert tokenId to hex and pad to 32 bytes
    final tokenIdBigInt = BigInt.parse(tokenId);
    final paddedTokenId = tokenIdBigInt.toRadixString(16).padLeft(64, '0');

    // Encode string (location name)
    // String encoding: offset (32 bytes) + length (32 bytes) + data (padded to 32 bytes)
    final locationBytes = utf8.encode(locationName);
    final locationLength = locationBytes.length
        .toRadixString(16)
        .padLeft(64, '0');
    final locationData = locationBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final paddedLocationData = locationData.padRight(
      (((locationData.length + 63) ~/ 64) * 64),
      '0',
    );

    // String offset is after address (32 bytes) and tokenId (32 bytes) = 64 bytes = 0x40 in hex
    const stringOffset =
        '0000000000000000000000000000000000000000000000000000000000000060'; // 96 bytes (3 * 32)

    // Combine all parts
    final encodedData =
        functionSelector +
        paddedAddress +
        paddedTokenId +
        stringOffset +
        locationLength +
        paddedLocationData;

    return encodedData;
  }

  /// Alternative: Open MetaMask app directly (simpler approach)
  static Future<bool> openMetaMaskApp() async {
    try {
      // Try direct MetaMask deep link
      final metamaskUri = Uri.parse('metamask://');

      if (await canLaunchUrl(metamaskUri)) {
        return await launchUrl(
          metamaskUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback to app link
      final appLink = Uri.parse('https://metamask.app.link/');
      if (await canLaunchUrl(appLink)) {
        return await launchUrl(appLink, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      print('Error opening MetaMask app: $e');
      return false;
    }
  }

  /// Check if MetaMask app is installed
  static Future<bool> isMetaMaskInstalled() async {
    try {
      final metamaskUri = Uri.parse('metamask://');
      return await canLaunchUrl(metamaskUri);
    } catch (e) {
      return false;
    }
  }
}
