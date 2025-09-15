
enum PropertyType {
  house,
  apartment,
  plot,
}

enum PropertyStatus {
  active,
  pending,
  sold,
  rented,
  inactive,
}

enum ListingType {
  sale, 
  rent, 
  auction, // for sale only
}

class PropertyModel {
  final String id;
  final String ownerId; // User who owns this property
  final String title;
  final String? description;
  final PropertyType propertyType;
  final ListingType listingType;
  final PropertyStatus status;
  final double? price;
  final double? rentPrice; // For properties available rent

// Address part
  final String address;
  final String city;
  final String district;
  final String postcode;
  final String division;
  final String subDistrict;
  final String country;
  final double? latitude;
  final double? longitude;
  
// Features depend on property type

// for Appartment 
  final int? bedrooms;
  final int? bathrooms;
  final int? balcony;
  final int? kitchen;


// for house 
  final int? yearBuilt;

// for plot

  final double squareFeet;
  final List<String> imageUrls;
  final Map<String, dynamic>? additionalDetails;
// entry info 
  final DateTime createdAt; 
  final DateTime updatedAt;

// property delete or not
  final isDeleted;

// property image
  final List<String>? propertyImg; 

// Filter 
  // near by alternative of google map

// Map Intregation
  // flutter map

// Constructor
  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.propertyType,
    required this.listingType,
    required this.status,
    this.price,
    this.rentPrice,
    required this.address,
    required this.city,
    required this.district,
    required this.postcode,
    required this.division,
    required this.subDistrict,
    required this.country,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.balcony,
    this.kitchen,
    this.yearBuilt,
    required this.squareFeet,
    required this.imageUrls,
    this.additionalDetails,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.propertyImg,
  });

// Convert to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'propertyType': propertyType.name,
      'listingType': listingType.name,
      'status': status.name,
      'price': price,
      'rentPrice': rentPrice,
      'address': address,
      'city': city,
      'district': district,
      'postcode': postcode,
      'division': division,
      'sub_district': subDistrict,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'balcony': balcony,
      'kitchen': kitchen,
      'yearBuilt': yearBuilt,
      'squareFeet': squareFeet,
      'imageUrls': imageUrls,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'propertyImg': propertyImg,
    };
  }

  /// Create from Map (from Firebase)
  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == map['propertyType'],
      ),
      listingType: ListingType.values.firstWhere(
        (e) => e.name == map['listingType'],
      ),
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      price: (map['price'] != null) ? (map['price'] as num).toDouble() : null,
      rentPrice:
          (map['rentPrice'] != null) ? (map['rentPrice'] as num).toDouble() : null,
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      postcode: map['postcode'] ?? '',
      division: map['division'] ?? '',
      subDistrict: map['sub_district'] ?? '',
      country: map['country'] ?? '',
      latitude: (map['latitude'] != null) ? (map['latitude'] as num).toDouble() : null,
      longitude: (map['longitude'] != null) ? (map['longitude'] as num).toDouble() : null,
      bedrooms: map['bedrooms'],
      bathrooms: map['bathrooms'],
      balcony: map['balcony'],
      kitchen: map['kitchen'],
      yearBuilt: map['yearBuilt'],
      squareFeet: (map['squareFeet'] as num).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      additionalDetails: Map<String, dynamic>.from(map['additionalDetails'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isDeleted: map['isDeleted'] ?? false,
      propertyImg:List<String>.from(map['images'] ?? []),
    );
  }
  PropertyModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    PropertyType? propertyType,
    ListingType? listingType,
    PropertyStatus? status,
    double? price,
    double? rentPrice,
    String? address,
    String? city,
    String? district,
    String? postcode,
    String? division,
    String? subDistrict,
    String? country,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    int? balcony,
    int? kitchen,
    int? yearBuilt,
    double? squareFeet,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<String>? propertyImg,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      price: price ?? this.price,
      rentPrice: rentPrice ?? this.rentPrice,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      postcode: postcode ?? this.postcode,
      division: division ?? this.division,
      subDistrict: subDistrict ?? this.subDistrict,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      balcony: balcony ?? this.balcony,
      kitchen: kitchen ?? this.kitchen,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      squareFeet: squareFeet ?? this.squareFeet,
      imageUrls: imageUrls ?? this.imageUrls,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      propertyImg: propertyImg ?? this.propertyImg,
    );
  }
}