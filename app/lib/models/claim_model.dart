import 'package:json_annotation/json_annotation.dart';

part 'claim_model.g.dart';

enum ClaimStatus {
  underReview,
  verified,
  approved,
  paid,
  rejected
}

enum DisasterType {
  flood,
  drought,
  pestAttack,
  disease,
  hailstorm,
  cyclone,
  fire,
  other
}

@JsonSerializable()
class Claim {
  final String id;
  final String farmerId;
  final String cropId;
  final DisasterType disasterType;
  final String description;
  final double estimatedLoss; // in percentage
  final double estimatedValue; // in rupees
  final List<String> imageUrls;
  final ClaimStatus status;
  final DateTime disasterDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remarks;
  final double? approvedAmount;
  final DateTime? paymentDate;

  const Claim({
    required this.id,
    required this.farmerId,
    required this.cropId,
    required this.disasterType,
    required this.description,
    required this.estimatedLoss,
    required this.estimatedValue,
    required this.imageUrls,
    required this.status,
    required this.disasterDate,
    required this.createdAt,
    required this.updatedAt,
    this.remarks,
    this.approvedAmount,
    this.paymentDate,
  });

  factory Claim.fromJson(Map<String, dynamic> json) => _$ClaimFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimToJson(this);

  Claim copyWith({
    String? id,
    String? farmerId,
    String? cropId,
    DisasterType? disasterType,
    String? description,
    double? estimatedLoss,
    double? estimatedValue,
    List<String>? imageUrls,
    ClaimStatus? status,
    DateTime? disasterDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
    double? approvedAmount,
    DateTime? paymentDate,
  }) {
    return Claim(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cropId: cropId ?? this.cropId,
      disasterType: disasterType ?? this.disasterType,
      description: description ?? this.description,
      estimatedLoss: estimatedLoss ?? this.estimatedLoss,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      disasterDate: disasterDate ?? this.disasterDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  String get disasterTypeDisplayName {
    switch (disasterType) {
      case DisasterType.flood:
        return 'Flood';
      case DisasterType.drought:
        return 'Drought';
      case DisasterType.pestAttack:
        return 'Pest Attack';
      case DisasterType.disease:
        return 'Disease';
      case DisasterType.hailstorm:
        return 'Hailstorm';
      case DisasterType.cyclone:
        return 'Cyclone';
      case DisasterType.fire:
        return 'Fire';
      case DisasterType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.verified:
        return 'Verified';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.paid:
        return 'Paid';
      case ClaimStatus.rejected:
        return 'Rejected';
    }
  }
}
