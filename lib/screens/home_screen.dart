import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nft_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/nft_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _totalLocations = 0;
  int _visitedLocations = 0;
  int _remainingLocations = 0;
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatistics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    final allLocations = NFTService.getSampleLocations();
    final claimedIds = await NFTService.getClaimedNFTIds();
    
    setState(() {
      _totalLocations = allLocations.length;
      _visitedLocations = claimedIds.length;
      _remainingLocations = _totalLocations - _visitedLocations;
      _completionPercentage = _totalLocations > 0 
          ? (_visitedLocations / _totalLocations) * 100 
          : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nftProvider = context.watch<NFTProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    // Refresh stats when provider changes (e.g., after claiming)
    if (nftProvider.claimedNFTs.length != _visitedLocations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStatistics();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('India NFT Explorer'),
        actions: [
          // Wallet Connection Button
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.02),
            child: walletProvider.isConnected
                ? Chip(
                    avatar: const Icon(Icons.account_balance_wallet, size: 18),
                    label: Text(
                      walletProvider.displayAddress,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => walletProvider.disconnectWallet(),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  )
                : IconButton(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/wallet-connect');
                    },
                    tooltip: 'Connect Wallet',
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadStatistics();
              nftProvider.loadAvailableNFTs();
              nftProvider.loadClaimedNFTs();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStatistics();
          await nftProvider.loadAvailableNFTs();
          await nftProvider.loadClaimedNFTs();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                            size: size.width * 0.06,
                          ),
                          SizedBox(width: size.width * 0.03),
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        dateFormat.format(now),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        timeFormat.format(now),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      size,
                      'Total Locations',
                      _totalLocations.toString(),
                      Icons.location_on,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      size,
                      'Visited',
                      _visitedLocations.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      size,
                      'Remaining',
                      _remainingLocations.toString(),
                      Icons.explore,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      size,
                      'Progress',
                      '${_completionPercentage.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              
              // Progress Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collection Progress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '$_visitedLocations / $_totalLocations',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _completionPercentage / 100,
                          minHeight: size.height * 0.02,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              
              // Wallet Status Card
              if (!walletProvider.isConnected)
                Card(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/wallet-connect');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.primary,
                            size: size.width * 0.08,
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connect Wallet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  'Connect your wallet to claim NFTs on the blockchain',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: size.width * 0.05,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (walletProvider.isConnected) ...[
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        SizedBox(width: size.width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Connected',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                walletProvider.walletAddress ?? '',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ],
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      size,
                      'Explore Map',
                      Icons.map,
                      Colors.blue,
                      () {
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      size,
                      'View NFTs',
                      Icons.collections,
                      Colors.purple,
                      () {
                        Navigator.pushNamed(context, '/available-nfts');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      size,
                      'My Collection',
                      Icons.folder,
                      Colors.green,
                      () {
                        Navigator.pushNamed(context, '/collections');
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      size,
                      'Claim Range',
                      Icons.location_searching,
                      Colors.orange,
                      () {
                        _showClaimRangeInfo(context, size);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    Size size,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: size.width * 0.08,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    Size size,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: size.width * 0.1,
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimRangeInfo(BuildContext context, Size size) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim Range Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To claim an NFT, you must be within 20 meters of the location.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: size.width * 0.02),
                Expanded(
                  child: Text(
                    'Make sure location services are enabled and you are physically present at the location.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

