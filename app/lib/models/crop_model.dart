import 'package:json_annotation/json_annotation.dart';

part 'crop_model.g.dart';

enum CropType {
  rice,
  wheat,
  maize,
  cotton,
  sugarcane,
  potato,
  tomato,
  onion,
  chili,
  other
}

enum CropStage {
  sowing,
  vegetative,
  flowering,
  fruiting,
  harvest
}

@JsonSerializable()
class Crop {
  final String id;
  final String farmerId;
  final String plotId; // Reference to the plot this crop belongs to
  final String name;
  final CropType type;
  final DateTime sowingDate;
  final double area; // in acres
  final double latitude;
  final double longitude;
  final String address;
  final String? imageUrl;
  final CropStage currentStage;
  final List<CropImage> weeklyImages; // Weekly crop images for monitoring
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  const Crop({
    required this.id,
    required this.farmerId,
    required this.plotId,
    required this.name,
    required this.type,
    required this.sowingDate,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    required this.currentStage,
    this.weeklyImages = const [],
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => _$CropFromJson(json);
  Map<String, dynamic> toJson() => _$CropToJson(this);

  Crop copyWith({
    String? id,
    String? farmerId,
    String? plotId,
    String? name,
    CropType? type,
    DateTime? sowingDate,
    double? area,
    double? latitude,
    double? longitude,
    String? address,
    String? imageUrl,
    CropStage? currentStage,
    List<CropImage>? weeklyImages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return Crop(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      plotId: plotId ?? this.plotId,
      name: name ?? this.name,
      type: type ?? this.type,
      sowingDate: sowingDate ?? this.sowingDate,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      currentStage: currentStage ?? this.currentStage,
      weeklyImages: weeklyImages ?? this.weeklyImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case CropType.rice:
        return 'Rice';
      case CropType.wheat:
        return 'Wheat';
      case CropType.maize:
        return 'Maize';
      case CropType.cotton:
        return 'Cotton';
      case CropType.sugarcane:
        return 'Sugarcane';
      case CropType.potato:
        return 'Potato';
      case CropType.tomato:
        return 'Tomato';
      case CropType.onion:
        return 'Onion';
      case CropType.chili:
        return 'Chili';
      case CropType.other:
        return 'Other';
    }
  }

  String get stageDisplayName {
    switch (currentStage) {
      case CropStage.sowing:
        return 'Sowing';
      case CropStage.vegetative:
        return 'Vegetative';
      case CropStage.flowering:
        return 'Flowering';
      case CropStage.fruiting:
        return 'Fruiting';
      case CropStage.harvest:
        return 'Harvest';
    }
  }
}

// @JsonSerializable()
class CropImage {
  final String id;
  final String cropId;
  final String imageUrl;
  final DateTime capturedDate;
  final String? notes;
  final CropHealthPrediction? healthPrediction; // ML model prediction

  const CropImage({
    required this.id,
    required this.cropId,
    required this.imageUrl,
    required this.capturedDate,
    this.notes,
    this.healthPrediction,
  });

  // Temporary manual JSON conversion
  factory CropImage.fromJson(Map<String, dynamic> json) {
    return CropImage(
      id: json['id'] as String,
      cropId: json['cropId'] as String,
      imageUrl: json['imageUrl'] as String,
      capturedDate: DateTime.parse(json['capturedDate'] as String),
      notes: json['notes'] as String?,
      healthPrediction: json['healthPrediction'] != null
          ? CropHealthPrediction.fromJson(json['healthPrediction'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'imageUrl': imageUrl,
      'capturedDate': capturedDate.toIso8601String(),
      'notes': notes,
      'healthPrediction': healthPrediction?.toJson(),
    };
  }
}

// @JsonSerializable()
class CropHealthPrediction {
  final bool isHealthy;
  final double confidence; // 0.0 to 1.0
  final String? diseaseType; // If unhealthy, what disease/problem
  final List<String> recommendations; // Care suggestions

  const CropHealthPrediction({
    required this.isHealthy,
    required this.confidence,
    this.diseaseType,
    this.recommendations = const [],
  });

  // Temporary manual JSON conversion
  factory CropHealthPrediction.fromJson(Map<String, dynamic> json) {
    return CropHealthPrediction(
      isHealthy: json['isHealthy'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      diseaseType: json['diseaseType'] as String?,
      recommendations: List<String>.from(json['recommendations'] as List? ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'isHealthy': isHealthy,
      'confidence': confidence,
      'diseaseType': diseaseType,
      'recommendations': recommendations,
    };
  }
}
