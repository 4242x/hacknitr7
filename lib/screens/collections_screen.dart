import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/nft_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/nft_model.dart';
import '../theme/app_theme.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Collection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (walletProvider.isConnected)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                     walletProvider.displayAddress.length > 6 
                      ? '${walletProvider.displayAddress.substring(0,6)}...' 
                      : walletProvider.displayAddress,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.deepBackground,
              Color(0xFF0F1218),
            ],
          ),
        ),
        child: !walletProvider.isConnected
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGlass,
                          shape: BoxShape.circle,
                          boxShadow: [
                             BoxShadow(
                               color: AppTheme.primaryPurple.withOpacity(0.2),
                               blurRadius: 20,
                               spreadRadius: 5,
                             )
                          ]
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 60,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Connect Wallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Connect your wallet to view your NFT collection and claim new items.',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletConnectScreen(),
                            ),
                          );
                        },
                        child: Text('Connect Now'),
                      ),
                    ],
                  ),
                ),
              )
            : nftProvider.isLoading && nftProvider.claimedNFTs.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  )
                : nftProvider.claimedNFTs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.collections_outlined,
                              size: 80,
                              color: Colors.white10,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'No NFTs found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start exploring to collect items!',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => nftProvider.loadClaimedNFTs(),
                         color: AppTheme.accentCyan,
                         backgroundColor: AppTheme.surfaceDark,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(child: SizedBox(height: 100)), // AppBar spacing
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: size.width > 600 ? 3 : 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final nft = nftProvider.claimedNFTs[index];
                                    return _buildCollectionCard(context, nft);
                                  },
                                  childCount: nftProvider.claimedNFTs.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, NFTModel nft) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/nft-detail',
          arguments: nft.tokenId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: nft.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                       color: AppTheme.surfaceDark,
                       child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPurple)),
                    ),
                    errorWidget: (context, url, error) => Container(
                       color: AppTheme.surfaceDark,
                       child: Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                   Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan,
                        borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(color: AppTheme.accentCyan.withOpacity(0.4), blurRadius: 8),
                         ]
                      ),
                      child: Text(
                        'OWNED',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nft.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                     if (nft.claimedAt != null)
                      Text(
                        'Claimed ${_formatDate(nft.claimedAt!)}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
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
