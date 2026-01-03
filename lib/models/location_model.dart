class LocationModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String nftTokenId;
  final String nftContractAddress;

  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.nftTokenId,
    required this.nftContractAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'nftTokenId': nftTokenId,
      'nftContractAddress': nftContractAddress,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      imageUrl: json['imageUrl'] as String,
      nftTokenId: json['nftTokenId'] as String,
      nftContractAddress: json['nftContractAddress'] as String,
    );
  }
}





