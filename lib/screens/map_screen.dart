import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/nft_provider.dart';
import '../services/nft_service.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  bool _hasRequestedLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load NFTs, don't request location automatically
      context.read<NFTProvider>().loadAvailableNFTs();
    });
  }

  Future<void> _requestLocationPermission() async {
    if (_hasRequestedLocation) return;
    
    _hasRequestedLocation = true;
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getCurrentLocation();
    
    if (locationProvider.currentPosition != null && mounted) {
      _mapController.move(
        LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            shape: BoxShape.circle,
          ),
          child: BackButton(color: Colors.white),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Explore Map',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
               color: AppTheme.surfaceDark,
               shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                locationProvider.isTracking
                    ? Icons.location_on
                    : Icons.location_off,
                 color: locationProvider.isTracking ? AppTheme.accentCyan : Colors.white54,
              ),
              onPressed: () {
                if (locationProvider.isTracking) {
                  locationProvider.stopTracking();
                } else {
                  locationProvider.startTracking();
                }
              },
              tooltip: locationProvider.isTracking
                  ? 'Stop Tracking'
                  : 'Start Tracking',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locationProvider.currentPosition != null
                  ? LatLng(
                      locationProvider.currentPosition!.latitude,
                      locationProvider.currentPosition!.longitude,
                    )
                  : const LatLng(23.0225, 72.5714), // Default to center of India
              initialZoom: 5.0, 
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                // Use CartoDB Dark Matter for dark theme
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.blo_trav',
              ),
              // User location marker
              if (locationProvider.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationProvider.currentPosition!.latitude,
                        locationProvider.currentPosition!.longitude,
                      ),
                      width: size.width * 0.08,
                      height: size.width * 0.08,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Location markers
              MarkerLayer(
                markers: _buildLocationMarkers(
                  NFTService.getSampleLocations(),
                  size,
                  context,
                ),
              ),
            ],
          ),
          // Info card
          if (locationProvider.error != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          locationProvider.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => locationProvider.clearError(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _requestLocationPermission();
        },
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        tooltip: 'Get My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Marker> _buildLocationMarkers(
    List<LocationModel> locations,
    Size size,
    BuildContext context,
  ) {
    return locations.map((location) {
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Column(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.5), blurRadius: 10),
                  ]
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
               Container(
                 width: 8,
                 height: 8,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: Colors.black54, blurRadius: 4),
                   ]
                 ),
               ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showLocationDetails(BuildContext context, LocationModel location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white10),
        ),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_city, color: AppTheme.accentCyan, size: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    location.name,
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              location.description,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/nft-detail',
                    arguments: location.nftTokenId,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View Location NFT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
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
