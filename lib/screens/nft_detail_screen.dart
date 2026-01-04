import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/nft_provider.dart';
import '../providers/location_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/nft_service.dart';
import '../models/nft_model.dart';
import '../theme/app_theme.dart';
import 'wallet_connect_screen.dart';
import 'transaction_signing_screen.dart';

class NFTDetailScreen extends StatefulWidget {
  final String tokenId;

  const NFTDetailScreen({super.key, required this.tokenId});

  @override
  State<NFTDetailScreen> createState() => _NFTDetailScreenState();
}

class _NFTDetailScreenState extends State<NFTDetailScreen> {
  NFTModel? _nft;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;

  @override
  void initState() {
    super.initState();
    _loadNFT();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showTitleInAppBar) {
        setState(() => _showTitleInAppBar = true);
      } else if (_scrollController.offset <= 300 && _showTitleInAppBar) {
        setState(() => _showTitleInAppBar = false);
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      _showConnectWalletDialog();
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
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate claim (location check)
    final canClaim = await nftProvider.claimNFT(
      widget.tokenId,
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
      walletProvider.walletAddress,
    );

    if (!mounted) return;

    if (!canClaim) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nftProvider.error ?? 'Failed to claim NFT'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Open transaction signing screen
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionSigningScreen(
          tokenId: widget.tokenId,
          recipientAddress: walletProvider.walletAddress!,
          locationName: _nft?.name ?? 'Location ${widget.tokenId}',
        ),
      ),
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      // Save claim locally
      final saved = await NFTService.claimNFT(
        widget.tokenId,
        walletProvider.walletAddress!,
      );

      if (saved) {
        // Reload NFTs
        await nftProvider.loadAvailableNFTs();
        await nftProvider.loadClaimedNFTs();
        await _loadNFT();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
               children: [
                 Icon(Icons.check_circle, color: Colors.white),
                 SizedBox(width: 8),
                 Expanded(child: Text('NFT claimed successfully!')),
               ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction successful but failed to save locally'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (result != null && result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Transaction failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showConnectWalletDialog() {
     showDialog(
        context: context,
        builder: (context) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: AppTheme.surfaceDark.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white10),
              ),
              title: Text('Wallet Required', style: TextStyle(color: Colors.white)),
              content: Text(
                'Please connect your wallet to claim this NFT location.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletConnectScreen(),
                      ),
                    );
                  },
                  child: Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nftProvider = context.watch<NFTProvider>();

    if (_isLoading || _nft == null) {
      return Scaffold(
        backgroundColor: AppTheme.deepBackground,
        appBar: AppBar(
             iconTheme: IconThemeData(color: Colors.white),
             backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryPurple,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showTitleInAppBar ? AppTheme.deepBackground.withOpacity(0.9) : Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26, 
            shape: BoxShape.circle,
          ),
          child: BackButton(color: Colors.white),
        ),
        title: _showTitleInAppBar 
            ? Text(_nft!.name, style: TextStyle(color: Colors.white, fontSize: 16))
            : null,
      ),
      body: Stack(
        children: [
          // Full screen image with parallax-like effect (simple via stack)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: CachedNetworkImage(
              imageUrl: _nft!.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.surfaceDark,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceDark,
                child: Icon(Icons.image_not_supported, color: Colors.white24, size: 50),
              ),
            ),
          ),
          
          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    AppTheme.deepBackground.withOpacity(0.8),
                    AppTheme.deepBackground,
                  ],
                  stops: [0.0, 0.4, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(top: size.height * 0.4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _nft!.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (_nft!.isClaimed)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'OWNED',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Location Pill
                    if (_nft!.location != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 24),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGlass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Icon(Icons.location_on, color: AppTheme.accentCyan, size: 20),
                             SizedBox(width: 8),
                             Flexible(
                               child: Text(
                                 _nft!.location!.name,
                                 style: TextStyle(color: Colors.white70),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             SizedBox(width: 12),
                             Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                          ],
                        ),
                      ),
                    
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _nft!.description,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Details Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildDetailCard(
                          'Coordinates',
                          '${_nft!.location?.latitude.toStringAsFixed(3)}, ${_nft!.location?.longitude.toStringAsFixed(3)}',
                          Icons.radar,
                        ),
                         _buildDetailCard(
                          'Token ID',
                          '#${widget.tokenId.substring(0, widget.tokenId.length > 6 ? 6 : widget.tokenId.length)}...',
                          Icons.fingerprint,
                        ),
                         if (_nft!.claimedAt != null)
                           _buildDetailCard(
                             'Claimed On',
                             _formatDate(_nft!.claimedAt!),
                             Icons.calendar_today,
                           ),
                      ],
                    ),
                    
                     if (_nft!.ownerAddress != null) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                             color: AppTheme.surfaceDark,
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Owner Address', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              SizedBox(height: 4),
                              Text(
                                _nft!.ownerAddress!,
                                style: TextStyle(color: AppTheme.accentCyan, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                     ],
                    
                    SizedBox(height: 100), // Spacer for fab
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_nft!.isClaimed ? Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: nftProvider.isLoading ? null : _claimNFT,
          backgroundColor: AppTheme.primaryPurple,
          elevation: 10,
          label: nftProvider.isLoading
           ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
           : Text('Claim Location NFT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          icon: nftProvider.isLoading ? null : Icon(Icons.explore),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
