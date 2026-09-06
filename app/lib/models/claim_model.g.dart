// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Claim _$ClaimFromJson(Map<String, dynamic> json) => Claim(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      cropId: json['cropId'] as String,
      disasterType: $enumDecode(_$DisasterTypeEnumMap, json['disasterType']),
      description: json['description'] as String,
      estimatedLoss: (json['estimatedLoss'] as num).toDouble(),
      estimatedValue: (json['estimatedValue'] as num).toDouble(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecode(_$ClaimStatusEnumMap, json['status']),
      disasterDate: DateTime.parse(json['disasterDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      remarks: json['remarks'] as String?,
      approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
    );

Map<String, dynamic> _$ClaimToJson(Claim instance) => <String, dynamic>{
      'id': instance.id,
      'farmerId': instance.farmerId,
      'cropId': instance.cropId,
      'disasterType': _$DisasterTypeEnumMap[instance.disasterType]!,
      'description': instance.description,
      'estimatedLoss': instance.estimatedLoss,
      'estimatedValue': instance.estimatedValue,
      'imageUrls': instance.imageUrls,
      'status': _$ClaimStatusEnumMap[instance.status]!,
      'disasterDate': instance.disasterDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'remarks': instance.remarks,
      'approvedAmount': instance.approvedAmount,
      'paymentDate': instance.paymentDate?.toIso8601String(),
    };

const _$DisasterTypeEnumMap = {
  DisasterType.flood: 'flood',
  DisasterType.drought: 'drought',
  DisasterType.pestAttack: 'pestAttack',
  DisasterType.disease: 'disease',
  DisasterType.hailstorm: 'hailstorm',
  DisasterType.cyclone: 'cyclone',
  DisasterType.fire: 'fire',
  DisasterType.other: 'other',
};

const _$ClaimStatusEnumMap = {
  ClaimStatus.underReview: 'underReview',
  ClaimStatus.verified: 'verified',
  ClaimStatus.approved: 'approved',
  ClaimStatus.paid: 'paid',
  ClaimStatus.rejected: 'rejected',
};
