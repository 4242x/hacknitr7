import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/nft_model.dart';

class NFTService {
  static const String _claimedNftsKey = 'claimed_nfts';
  static const double _claimRangeMeters = 20.0; // 20 meters range to claim

  // Kolkata locations - in a real app, these would come from a backend
  static List<LocationModel> getSampleLocations() {
    return [
      LocationModel(
        id: '1',
        name: 'Victoria Memorial',
        description: 'A magnificent marble building dedicated to Queen Victoria. Visit this iconic landmark to claim your exclusive NFT!',
        latitude: 22.5448,
        longitude: 88.3426,
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        nftTokenId: '1',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '2',
        name: 'Howrah Bridge',
        description: 'The iconic cantilever bridge over the Hooghly River. Cross this engineering marvel to earn your commemorative NFT.',
        latitude: 22.5950,
        longitude: 88.3467,
        imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574028edf?w=800',
        nftTokenId: '2',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '3',
        name: 'Indian Museum',
        description: 'Explore the rich history and culture of India. This NFT commemorates your visit to one of the oldest museums in the world.',
        latitude: 22.5586,
        longitude: 88.3509,
        imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
        nftTokenId: '3',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '4',
        name: 'Park Street',
        description: 'The vibrant heart of Kolkata\'s nightlife and dining scene. Visit this famous street to claim your urban explorer NFT.',
        latitude: 22.5483,
        longitude: 88.3528,
        imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
        nftTokenId: '4',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '5',
        name: 'St. Paul\'s Cathedral',
        description: 'A beautiful Gothic-style cathedral in the heart of Kolkata. Visit this architectural gem to claim your NFT.',
        latitude: 22.5444,
        longitude: 88.3511,
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
        nftTokenId: '5',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '6',
        name: 'Kalighat Temple',
        description: 'One of the 51 Shakti Peethas, this ancient temple is a major pilgrimage site. Visit to claim your spiritual NFT.',
        latitude: 22.5203,
        longitude: 88.3422,
        imageUrl: 'https://images.unsplash.com/photo-1580322143841-8c4e0e3e1c5f?w=800',
        nftTokenId: '6',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '7',
        name: 'Science City',
        description: 'A science museum and educational center. Explore the wonders of science and claim your educational NFT.',
        latitude: 22.5333,
        longitude: 88.3889,
        imageUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800',
        nftTokenId: '7',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '8',
        name: 'Eden Gardens',
        description: 'The iconic cricket stadium, one of the largest in the world. Visit this sporting landmark to claim your NFT.',
        latitude: 22.5645,
        longitude: 88.3433,
        imageUrl: 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
        nftTokenId: '8',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '9',
        name: 'Marble Palace',
        description: 'A 19th-century mansion with beautiful architecture and art collection. Visit this heritage building to claim your NFT.',
        latitude: 22.5700,
        longitude: 88.3500,
        imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
        nftTokenId: '9',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '10',
        name: 'Belur Math',
        description: 'The headquarters of Ramakrishna Math and Mission. Visit this serene spiritual center to claim your NFT.',
        latitude: 22.6300,
        longitude: 88.3567,
        imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574028edf?w=800',
        nftTokenId: '10',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
    ];
  }

  static Future<List<NFTModel>> getAllAvailableNFTs() async {
    List<LocationModel> locations = getSampleLocations();
    List<String> claimedIds = await getClaimedNFTIds();
    
    return locations.map((location) {
      bool isClaimed = claimedIds.contains(location.nftTokenId);
      return NFTModel(
        tokenId: location.nftTokenId,
        contractAddress: location.nftContractAddress,
        name: location.name,
        description: location.description,
        imageUrl: location.imageUrl,
        location: location,
        isClaimed: isClaimed,
      );
    }).toList();
  }

  static Future<List<NFTModel>> getClaimedNFTs() async {
    List<LocationModel> locations = getSampleLocations();
    List<String> claimedIds = await getClaimedNFTIds();
    
    List<NFTModel> claimedNFTs = [];
    for (var location in locations) {
      if (claimedIds.contains(location.nftTokenId)) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? claimedData = prefs.getString('${_claimedNftsKey}_${location.nftTokenId}');
        Map<String, dynamic>? data = claimedData != null ? jsonDecode(claimedData) : null;
        
        claimedNFTs.add(NFTModel(
          tokenId: location.nftTokenId,
          contractAddress: location.nftContractAddress,
          name: location.name,
          description: location.description,
          imageUrl: location.imageUrl,
          location: location,
          isClaimed: true,
          claimedAt: data != null && data['claimedAt'] != null
              ? DateTime.parse(data['claimedAt'])
              : DateTime.now(),
          ownerAddress: data?['ownerAddress'] as String?,
        ));
      }
    }
    
    return claimedNFTs;
  }

  static Future<List<String>> getClaimedNFTIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? claimedIdsJson = prefs.getString(_claimedNftsKey);
    if (claimedIdsJson == null) {
      return [];
    }
    List<dynamic> decoded = jsonDecode(claimedIdsJson);
    return decoded.cast<String>();
  }

  static Future<bool> claimNFT(String tokenId, String ownerAddress) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> claimedIds = await getClaimedNFTIds();
      
      if (!claimedIds.contains(tokenId)) {
        claimedIds.add(tokenId);
        await prefs.setString(_claimedNftsKey, jsonEncode(claimedIds));
        
        // Store claim details
        Map<String, dynamic> claimData = {
          'claimedAt': DateTime.now().toIso8601String(),
          'ownerAddress': ownerAddress,
        };
        await prefs.setString('${_claimedNftsKey}_$tokenId', jsonEncode(claimData));
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canClaimNFT(
    double userLat,
    double userLon,
    LocationModel location,
  ) async {
    List<String> claimedIds = await getClaimedNFTIds();
    if (claimedIds.contains(location.nftTokenId)) {
      return false; // Already claimed
    }

    double distance = _calculateDistance(
      userLat,
      userLon,
      location.latitude,
      location.longitude,
    );

    return distance <= _claimRangeMeters;
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

