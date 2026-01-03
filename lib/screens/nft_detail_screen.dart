import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/nft_provider.dart';
import '../providers/location_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/nft_service.dart';
import '../models/nft_model.dart';
import 'wallet_connect_screen.dart';

class NFTDetailScreen extends StatefulWidget {
  final String tokenId;

  const NFTDetailScreen({super.key, required this.tokenId});

  @override
  State<NFTDetailScreen> createState() => _NFTDetailScreenState();
}

class _NFTDetailScreenState extends State<NFTDetailScreen> {
  NFTModel? _nft;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNFT();
  }

  Future<void> _loadNFT() async {
    setState(() => _isLoading = true);
    final allNFTs = await NFTService.getAllAvailableNFTs();
    _nft = allNFTs.firstWhere(
      (nft) => nft.tokenId == widget.tokenId,
      orElse: () {
        final claimed = context.read<NFTProvider>().claimedNFTs;
        return claimed.firstWhere(
          (nft) => nft.tokenId == widget.tokenId,
        );
      },
    );
    setState(() => _isLoading = false);
  }

  Future<void> _claimNFT() async {
    final locationProvider = context.read<LocationProvider>();
    final nftProvider = context.read<NFTProvider>();
    final walletProvider = context.read<WalletProvider>();

    // Check if wallet is connected
    if (!walletProvider.isConnected || walletProvider.walletAddress == null) {
      if (!mounted) return;
      final shouldConnect = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Wallet Not Connected'),
          content: Text('Please connect your wallet to claim NFTs.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Connect Wallet'),
            ),
          ],
        ),
      );
      
      if (shouldConnect == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletConnectScreen(),
          ),
        );
      }
      return;
    }

    if (locationProvider.currentPosition == null) {
      await locationProvider.getCurrentLocation();
    }

    if (locationProvider.currentPosition == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get your location. Please enable location services.'),
        ),
      );
      return;
    }

    final success = await nftProvider.claimNFT(
      widget.tokenId,
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
      walletProvider.walletAddress,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFT claimed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadNFT();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nftProvider.error ?? 'Failed to claim NFT'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nftProvider = context.watch<NFTProvider>();

    if (_isLoading || _nft == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('NFT Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFT Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Image
            Container(
              width: double.infinity,
              height: size.height * 0.4,
              color: Colors.grey[300],
              child: CachedNetworkImage(
                imageUrl: _nft!.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                ),
              ),
            ),
            // NFT Info
            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _nft!.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (_nft!.isClaimed)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.width * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CLAIMED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    _nft!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_nft!.location != null) ...[
                    SizedBox(height: size.height * 0.03),
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(_nft!.location!.name),
                        subtitle: Text(
                          '${_nft!.location!.latitude.toStringAsFixed(4)}, ${_nft!.location!.longitude.toStringAsFixed(4)}',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/map');
                        },
                      ),
                    ),
                  ],
                  if (_nft!.claimedAt != null) ...[
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Claimed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      _formatDate(_nft!.claimedAt!),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (_nft!.ownerAddress != null) ...[
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Owner',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      _nft!.ownerAddress!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                  SizedBox(height: size.height * 0.03),
                  if (!_nft!.isClaimed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nftProvider.isLoading ? null : _claimNFT,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.02,
                          ),
                        ),
                        child: nftProvider.isLoading
                            ? SizedBox(
                                height: size.height * 0.02,
                                width: size.height * 0.02,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Claim NFT',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

