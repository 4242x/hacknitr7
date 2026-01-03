import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/nft_model.dart';

class NFTService {
  static const String _claimedNftsKey = 'claimed_nfts';
  static const double _claimRangeMeters = 20.0; // 20 meters range to claim

  // India locations - Iconic landmarks across the country
  static List<LocationModel> getSampleLocations() {
    return [
      // Delhi
      LocationModel(
        id: '1',
        name: 'Taj Mahal, Agra',
        description: 'The iconic white marble mausoleum, one of the Seven Wonders of the World. Visit this UNESCO World Heritage site to claim your exclusive NFT!',
        latitude: 27.1751,
        longitude: 78.0421,
        imageUrl: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800',
        nftTokenId: '1',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '2',
        name: 'Red Fort, Delhi',
        description: 'A historic fort and UNESCO World Heritage Site. Visit this symbol of Mughal power to earn your commemorative NFT.',
        latitude: 28.6562,
        longitude: 77.2410,
        imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574028edf?w=800',
        nftTokenId: '2',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '3',
        name: 'India Gate, Delhi',
        description: 'A war memorial dedicated to Indian soldiers. Visit this iconic monument to claim your NFT.',
        latitude: 28.6129,
        longitude: 77.2295,
        imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
        nftTokenId: '3',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Mumbai
      LocationModel(
        id: '4',
        name: 'Gateway of India, Mumbai',
        description: 'The iconic arch monument overlooking the Arabian Sea. Visit this symbol of Mumbai to claim your urban explorer NFT.',
        latitude: 18.9220,
        longitude: 72.8347,
        imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
        nftTokenId: '4',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '5',
        name: 'Marine Drive, Mumbai',
        description: 'The beautiful 3.6 km long promenade along the Arabian Sea. Visit this scenic boulevard to claim your NFT.',
        latitude: 18.9445,
        longitude: 72.8260,
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
        nftTokenId: '5',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Rajasthan
      LocationModel(
        id: '6',
        name: 'Hawa Mahal, Jaipur',
        description: 'The Palace of Winds with its unique honeycomb design. Visit this architectural marvel to claim your NFT.',
        latitude: 26.9239,
        longitude: 75.8267,
        imageUrl: 'https://images.unsplash.com/photo-1580322143841-8c4e0e3e1c5f?w=800',
        nftTokenId: '6',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '7',
        name: 'Amber Fort, Jaipur',
        description: 'A magnificent fort palace with stunning architecture. Visit this hilltop fortress to claim your NFT.',
        latitude: 27.1734,
        longitude: 75.8513,
        imageUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800',
        nftTokenId: '7',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Kerala
      LocationModel(
        id: '8',
        name: 'Backwaters, Alleppey',
        description: 'The serene network of canals and lagoons. Visit this natural wonder to claim your peaceful NFT.',
        latitude: 9.4981,
        longitude: 76.3388,
        imageUrl: 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
        nftTokenId: '8',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Tamil Nadu
      LocationModel(
        id: '9',
        name: 'Meenakshi Temple, Madurai',
        description: 'A historic Hindu temple dedicated to Goddess Meenakshi. Visit this architectural masterpiece to claim your NFT.',
        latitude: 9.9196,
        longitude: 78.1194,
        imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
        nftTokenId: '9',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // West Bengal
      LocationModel(
        id: '10',
        name: 'Victoria Memorial, Kolkata',
        description: 'A magnificent marble building dedicated to Queen Victoria. Visit this iconic landmark to claim your NFT.',
        latitude: 22.5448,
        longitude: 88.3426,
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        nftTokenId: '10',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Uttar Pradesh
      LocationModel(
        id: '11',
        name: 'Varanasi Ghats, Varanasi',
        description: 'The sacred riverfront steps along the Ganges. Visit this spiritual center to claim your NFT.',
        latitude: 25.3176,
        longitude: 83.0058,
        imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574028edf?w=800',
        nftTokenId: '11',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Karnataka
      LocationModel(
        id: '12',
        name: 'Mysore Palace, Mysore',
        description: 'The opulent royal residence of the Wadiyar dynasty. Visit this grand palace to claim your NFT.',
        latitude: 12.3052,
        longitude: 76.6552,
        imageUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
        nftTokenId: '12',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Gujarat
      LocationModel(
        id: '13',
        name: 'Sabarmati Ashram, Ahmedabad',
        description: 'Mahatma Gandhi\'s residence and center of India\'s freedom struggle. Visit this historic site to claim your NFT.',
        latitude: 23.0605,
        longitude: 72.5800,
        imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800',
        nftTokenId: '13',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Odisha
      LocationModel(
        id: '14',
        name: 'Konark Sun Temple, Odisha',
        description: 'A 13th-century temple dedicated to the Sun God. Visit this UNESCO World Heritage site to claim your NFT.',
        latitude: 19.8876,
        longitude: 86.0945,
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
        nftTokenId: '14',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Himachal Pradesh
      LocationModel(
        id: '15',
        name: 'Golden Temple, Amritsar',
        description: 'The holiest Gurdwara of Sikhism. Visit this spiritual center to claim your NFT.',
        latitude: 31.6200,
        longitude: 74.8765,
        imageUrl: 'https://images.unsplash.com/photo-1580322143841-8c4e0e3e1c5f?w=800',
        nftTokenId: '15',
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

