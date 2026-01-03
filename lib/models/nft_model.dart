import 'location_model.dart';

class NFTModel {
  final String tokenId;
  final String contractAddress;
  final String name;
  final String description;
  final String imageUrl;
  final LocationModel? location;
  final DateTime? claimedAt;
  final String? ownerAddress;
  final bool isClaimed;

  NFTModel({
    required this.tokenId,
    required this.contractAddress,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.location,
    this.claimedAt,
    this.ownerAddress,
    this.isClaimed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'contractAddress': contractAddress,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location?.toJson(),
      'claimedAt': claimedAt?.toIso8601String(),
      'ownerAddress': ownerAddress,
      'isClaimed': isClaimed,
    };
  }

  factory NFTModel.fromJson(Map<String, dynamic> json) {
    return NFTModel(
      tokenId: json['tokenId'] as String,
      contractAddress: json['contractAddress'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      claimedAt: json['claimedAt'] != null
          ? DateTime.parse(json['claimedAt'] as String)
          : null,
      ownerAddress: json['ownerAddress'] as String?,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}





