// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Crop _$CropFromJson(Map<String, dynamic> json) => Crop(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      plotId: json['plotId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CropTypeEnumMap, json['type']),
      sowingDate: DateTime.parse(json['sowingDate'] as String),
      area: (json['area'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String?,
      currentStage: $enumDecode(_$CropStageEnumMap, json['currentStage']),
      weeklyImages: (json['weeklyImages'] as List<dynamic>?)
          ?.map((e) => CropImage.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CropToJson(Crop instance) => <String, dynamic>{
      'id': instance.id,
      'farmerId': instance.farmerId,
      'plotId': instance.plotId,
      'name': instance.name,
      'type': _$CropTypeEnumMap[instance.type]!,
      'sowingDate': instance.sowingDate.toIso8601String(),
      'area': instance.area,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'imageUrl': instance.imageUrl,
      'currentStage': _$CropStageEnumMap[instance.currentStage]!,
      'weeklyImages': instance.weeklyImages.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'additionalData': instance.additionalData,
    };

const _$CropTypeEnumMap = {
  CropType.rice: 'rice',
  CropType.wheat: 'wheat',
  CropType.maize: 'maize',
  CropType.cotton: 'cotton',
  CropType.sugarcane: 'sugarcane',
  CropType.potato: 'potato',
  CropType.tomato: 'tomato',
  CropType.onion: 'onion',
  CropType.chili: 'chili',
  CropType.other: 'other',
};

const _$CropStageEnumMap = {
  CropStage.sowing: 'sowing',
  CropStage.vegetative: 'vegetative',
  CropStage.flowering: 'flowering',
  CropStage.fruiting: 'fruiting',
  CropStage.harvest: 'harvest',
};
