import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/nft_model.dart';

class NFTService {
  static const String _claimedNftsKey = 'claimed_nfts';
  static const double _claimRangeMeters = 700000.0; // 20 meters range to claim

  // India locations - Iconic landmarks across the country
  static List<LocationModel> getSampleLocations() {
    return [
      // Delhi
      LocationModel(
        id: '1',
        name: 'Taj Mahal, Agra',
        description:
            'The iconic white marble mausoleum, one of the Seven Wonders of the World. Visit this UNESCO World Heritage site to claim your exclusive NFT!',
        latitude: 27.1751,
        longitude: 78.0421,
        imageUrl:
            'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800',
        nftTokenId: '1',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '2',
        name: 'Red Fort, Delhi',
        description:
            'A historic fort and UNESCO World Heritage Site. Visit this symbol of Mughal power to earn your commemorative NFT.',
        latitude: 28.6562,
        longitude: 77.2410,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/7e/Agra_03-2016_10_Agra_Fort.jpg',
        nftTokenId: '2',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '3',
        name: 'India Gate, Delhi',
        description:
            'A war memorial dedicated to Indian soldiers. Visit this iconic monument to claim your NFT.',
        latitude: 28.6129,
        longitude: 77.2295,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/India_Gate_in_New_Delhi_03-2016.jpg/1638px-India_Gate_in_New_Delhi_03-2016.jpg',
        nftTokenId: '3',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Mumbai
      LocationModel(
        id: '4',
        name: 'Gateway of India, Mumbai',
        description:
            'The iconic arch monument overlooking the Arabian Sea. Visit this symbol of Mumbai to claim your urban explorer NFT.',
        latitude: 18.9220,
        longitude: 72.8347,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Mumbai_03-2016_30_Gateway_of_India.jpg/330px-Mumbai_03-2016_30_Gateway_of_India.jpg',
        nftTokenId: '4',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '5',
        name: 'Marine Drive, Mumbai',
        description:
            'The beautiful 3.6 km long promenade along the Arabian Sea. Visit this scenic boulevard to claim your NFT.',
        latitude: 18.9445,
        longitude: 72.8260,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Marine_Drive_Skyline.jpg/1200px-Marine_Drive_Skyline.jpg',
        nftTokenId: '5',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Rajasthan
      LocationModel(
        id: '6',
        name: 'Hawa Mahal, Jaipur',
        description:
            'The Palace of Winds with its unique honeycomb design. Visit this architectural marvel to claim your NFT.',
        latitude: 26.9239,
        longitude: 75.8267,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/41/East_facade_Hawa_Mahal_Jaipur_from_ground_level_%28July_2022%29_-_img_01.jpg',
        nftTokenId: '6',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      LocationModel(
        id: '7',
        name: 'Amber Fort, Jaipur',
        description:
            'A magnificent fort palace with stunning architecture. Visit this hilltop fortress to claim your NFT.',
        latitude: 27.1734,
        longitude: 75.8513,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/20191219_Fort_Amber%2C_Amer%2C_Jaipur_0955_9481.jpg/1200px-20191219_Fort_Amber%2C_Amer%2C_Jaipur_0955_9481.jpg',
        nftTokenId: '7',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Kerala
      LocationModel(
        id: '8',
        name: 'Backwaters, Alleppey',
        description:
            'The serene network of canals and lagoons. Visit this natural wonder to claim your peaceful NFT.',
        latitude: 9.4981,
        longitude: 76.3388,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Boathouse_%287063399547%29.jpg/500px-Boathouse_%287063399547%29.jpg',
        nftTokenId: '8',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Tamil Nadu
      LocationModel(
        id: '9',
        name: 'Meenakshi Temple, Madurai',
        description:
            'A historic Hindu temple dedicated to Goddess Meenakshi. Visit this architectural masterpiece to claim your NFT.',
        latitude: 9.9196,
        longitude: 78.1194,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg/1200px-An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg',
        nftTokenId: '9',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // West Bengal
      LocationModel(
        id: '10',
        name: 'Victoria Memorial, Kolkata',
        description:
            'A magnificent marble building dedicated to Queen Victoria. Visit this iconic landmark to claim your NFT.',
        latitude: 22.5448,
        longitude: 88.3426,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d8/Victoria_Memorial_Hall%2C_Megacity_Kolkata.jpg',
        nftTokenId: '10',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Uttar Pradesh
      LocationModel(
        id: '11',
        name: 'Varanasi Ghats, Varanasi',
        description:
            'The sacred riverfront steps along the Ganges. Visit this spiritual center to claim your NFT.',
        latitude: 25.3176,
        longitude: 83.0058,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/04/Ahilya_Ghat_by_the_Ganges%2C_Varanasi.jpg',
        nftTokenId: '11',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Karnataka
      LocationModel(
        id: '12',
        name: 'Mysore Palace, Mysore',
        description:
            'The opulent royal residence of the Wadiyar dynasty. Visit this grand palace to claim your NFT.',
        latitude: 12.3052,
        longitude: 76.6552,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Mysore_Palace_Morning.jpg/1200px-Mysore_Palace_Morning.jpg',
        nftTokenId: '12',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Gujarat
      LocationModel(
        id: '13',
        name: 'Sabarmati Ashram, Ahmedabad',
        description:
            'Mahatma Gandhi\'s residence and center of India\'s freedom struggle. Visit this historic site to claim your NFT.',
        latitude: 23.0605,
        longitude: 72.5800,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9a/GANDHI_ASHRAM_03.jpg',
        nftTokenId: '13',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Odisha
      LocationModel(
        id: '14',
        name: 'Konark Sun Temple, Odisha',
        description:
            'A 13th-century temple dedicated to the Sun God. Visit this UNESCO World Heritage site to claim your NFT.',
        latitude: 19.8876,
        longitude: 86.0945,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Sun_Temple_Konark_Puri_District_Odisha.jpg/2560px-Sun_Temple_Konark_Puri_District_Odisha.jpg',
        nftTokenId: '14',
        nftContractAddress: '0x0000000000000000000000000000000000000000',
      ),
      // Himachal Pradesh
      LocationModel(
        id: '15',
        name: 'Golden Temple, Amritsar',
        description:
            'The holiest Gurdwara of Sikhism. Visit this spiritual center to claim your NFT.',
        latitude: 31.6200,
        longitude: 74.8765,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/94/The_Golden_Temple_of_Amrithsar_7.jpg',
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
        String? claimedData = prefs.getString(
          '${_claimedNftsKey}_${location.nftTokenId}',
        );
        Map<String, dynamic>? data = claimedData != null
            ? jsonDecode(claimedData)
            : null;

        claimedNFTs.add(
          NFTModel(
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
          ),
        );
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
        await prefs.setString(
          '${_claimedNftsKey}_$tokenId',
          jsonEncode(claimData),
        );

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

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
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
