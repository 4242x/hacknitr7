import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/nft_provider.dart';
import '../services/nft_service.dart';
import '../models/location_model.dart';

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
      appBar: AppBar(
        title: const Text('Explore Locations'),
        actions: [
          IconButton(
            icon: Icon(
              locationProvider.isTracking
                  ? Icons.location_on
                  : Icons.location_off,
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
                  : const LatLng(22.5448, 88.3426), // Default to Kolkata
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 20,
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
              top: size.height * 0.02,
              left: size.width * 0.05,
              right: size.width * 0.05,
              child: Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.03),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      SizedBox(width: size.width * 0.02),
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
        width: size.width * 0.12,
        height: size.width * 0.12,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showLocationDetails(BuildContext context, LocationModel location) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: size.height * 0.01),
              width: size.width * 0.15,
              height: size.height * 0.005,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      location.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: size.height * 0.03),
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
                        child: const Text('View NFT Details'),
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

