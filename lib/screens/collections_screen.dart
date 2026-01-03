import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/nft_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/nft_model.dart';
import 'wallet_connect_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NFTProvider>().loadClaimedNFTs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nftProvider = context.watch<NFTProvider>();
    final walletProvider = context.watch<WalletProvider>();

    // Show connect wallet if not connected
    if (!walletProvider.isConnected) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Collection'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: size.width * 0.25,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  'Connect Your Wallet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Connect your wallet to view your NFT collection and claim new NFTs from locations.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletConnectScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_balance_wallet),
                  label: Text('Connect Wallet'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1,
                      vertical: size.height * 0.02,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Text('Go to Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          // Show wallet address in app bar
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.03),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.width * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      walletProvider.displayAddress,
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        fontFamily: 'monospace',
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: nftProvider.isLoading && nftProvider.claimedNFTs.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : nftProvider.error != null
              ? Center(
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
                        nftProvider.error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.02),
                      ElevatedButton(
                        onPressed: () => nftProvider.loadClaimedNFTs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : nftProvider.claimedNFTs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.collections_outlined,
                            size: size.width * 0.3,
                            color: Colors.grey,
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            'No NFTs claimed yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Visit locations to claim NFTs!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => nftProvider.loadClaimedNFTs(),
                      child: GridView.builder(
                        padding: EdgeInsets.all(size.width * 0.04),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size.width > 600 ? 3 : 2,
                          crossAxisSpacing: size.width * 0.04,
                          mainAxisSpacing: size.width * 0.04,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: nftProvider.claimedNFTs.length,
                        itemBuilder: (context, index) {
                          final nft = nftProvider.claimedNFTs[index];
                          return _buildNFTCard(context, nft, size);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNFTCard(BuildContext context, NFTModel nft, Size size) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/nft-detail',
            arguments: nft.tokenId,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: nft.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  Positioned(
                    top: size.width * 0.02,
                    right: size.width * 0.02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.width * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OWNED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.025,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // NFT Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nft.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.height * 0.005),
                    if (nft.claimedAt != null)
                      Text(
                        'Claimed: ${_formatDate(nft.claimedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}





