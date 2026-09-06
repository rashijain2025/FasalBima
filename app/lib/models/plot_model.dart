import 'package:json_annotation/json_annotation.dart';

// part 'plot_model.g.dart'; // Uncomment after running: flutter pub run build_runner build

@JsonSerializable()
class Plot {
  final String id;
  final String farmerId;
  final String name;
  final double area; // in acres
  final double latitude;
  final double longitude;
  final String address;
  final List<String> landDocumentUrls; // URLs of land ownership documents
  final DateTime registeredDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  const Plot({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.landDocumentUrls,
    required this.registeredDate,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // factory Plot.fromJson(Map<String, dynamic> json) => _$PlotFromJson(json);
  // Map<String, dynamic> toJson() => _$PlotToJson(this);
  
  // Temporary manual JSON conversion until build_runner generates the code
  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      name: json['name'] as String,
      area: (json['area'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      landDocumentUrls: List<String>.from(json['landDocumentUrls'] as List),
      registeredDate: DateTime.parse(json['registeredDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landDocumentUrls': landDocumentUrls,
      'registeredDate': registeredDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  Plot copyWith({
    String? id,
    String? farmerId,
    String? name,
    double? area,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? landDocumentUrls,
    DateTime? registeredDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return Plot(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      landDocumentUrls: landDocumentUrls ?? this.landDocumentUrls,
      registeredDate: registeredDate ?? this.registeredDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

