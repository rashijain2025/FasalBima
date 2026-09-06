// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData(
      location: json['location'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'location': instance.location,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'windSpeed': instance.windSpeed,
      'condition': instance.condition,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'alerts': instance.alerts,
    };

WeatherAlert _$WeatherAlertFromJson(Map<String, dynamic> json) => WeatherAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      type: json['type'] as String,
    );

Map<String, dynamic> _$WeatherAlertToJson(WeatherAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'severity': instance.severity,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'type': instance.type,
    };

FarmingTip _$FarmingTipFromJson(Map<String, dynamic> json) => FarmingTip(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      cropType: json['cropType'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$FarmingTipToJson(FarmingTip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'cropType': instance.cropType,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };
