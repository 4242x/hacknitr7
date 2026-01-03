import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/nft_provider.dart';
import '../models/nft_model.dart';

class AvailableNFTsScreen extends StatefulWidget {
  const AvailableNFTsScreen({super.key});

  @override
  State<AvailableNFTsScreen> createState() => _AvailableNFTsScreenState();
}

class _AvailableNFTsScreenState extends State<AvailableNFTsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NFTProvider>().loadAvailableNFTs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nftProvider = context.watch<NFTProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available NFTs'),
      ),
      body: nftProvider.isLoading && nftProvider.availableNFTs.isEmpty
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
                        onPressed: () => nftProvider.loadAvailableNFTs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : nftProvider.availableNFTs.isEmpty
                  ? Center(
                      child: Text(
                        'No NFTs available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => nftProvider.loadAvailableNFTs(),
                      child: GridView.builder(
                        padding: EdgeInsets.all(size.width * 0.04),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size.width > 600 ? 3 : 2,
                          crossAxisSpacing: size.width * 0.04,
                          mainAxisSpacing: size.width * 0.04,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: nftProvider.availableNFTs.length,
                        itemBuilder: (context, index) {
                          final nft = nftProvider.availableNFTs[index];
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
                  if (nft.isClaimed)
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
                          'CLAIMED',
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
                    Expanded(
                      child: Text(
                        nft.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}





