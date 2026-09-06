import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/weather_provider.dart' as weather;
import '../../providers/crop_provider.dart';
import '../../models/weather_model.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';

// localization
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  double? _lat;
  double? _lon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWeather();
    });
  }

  // Device ka current GPS location
  Future<Position?> _getCurrentPosition() async {
    final loc = AppLocalizations.of(context);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('ins_loc_service_off')),
          ),
        );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.t('ins_loc_perm_denied')),
            ),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.t('ins_loc_perm_denied_forever'),
            ),
          ),
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _initWeather() async {
    final loc = AppLocalizations.of(context);

    double? lat;
    double? lon;

    // 1️⃣ GPS
    try {
      final pos = await _getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lon = pos.longitude;
        debugPrint('📍 Using device location: lat=$lat, lon=$lon');
      }
    } catch (e) {
      debugPrint('⚠️ Error getting GPS location: $e');
    }

    // 2️⃣ crop location fallback
    if (lat == null || lon == null) {
      try {
        final crops = context.read<CropProvider>().crops;
        final first = crops.firstWhere(
          (c) => c.latitude != 0.0 && c.longitude != 0.0,
          orElse: () => crops.isNotEmpty
              ? crops.first
              : Crop(
                  id: '',
                  farmerId: '',
                  plotId: '',
                  name: '',
                  type: CropType.other,
                  sowingDate: DateTime.now(),
                  area: 0.0,
                  latitude: 0.0,
                  longitude: 0.0,
                  address: '',
                  imageUrl: null,
                  currentStage: CropStage.sowing,
                  weeklyImages: const [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  additionalData: const {},
                ),
        );
        if (first.latitude != 0.0 && first.longitude != 0.0) {
          lat = first.latitude;
          lon = first.longitude;
          debugPrint('📍 Using crop location: lat=$lat, lon=$lon');
        }
      } catch (e) {
        debugPrint('⚠️ Error getting crop location: $e');
      }
    }

    // 3️⃣ Delhi fallback
    lat ??= 28.6139;
    lon ??= 77.2090;
    debugPrint('📍 Fallback location (Delhi): lat=$lat, lon=$lon');

    if (!mounted) return;

    setState(() {
      _lat = lat;
      _lon = lon;
    });

    try {
      final wp = context.read<weather.WeatherProvider>();
      await wp.loadWeatherData(lat: lat, lon: lon);
      await wp.loadForecastData(lat: lat, lon: lon);
    } catch (e) {
      debugPrint('⚠️ _initWeather final error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.t('ins_err_fetch_weather')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = _lat;
    final lon = _lon;
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(loc.t('insights_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initWeather,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lat != null && lon != null) ...[
              Text(
                '${loc.t('ins_current_coords')} '
                '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            _buildWeatherDetails(context),
            const SizedBox(height: 24),
            _buildForecastSection(context),
            const SizedBox(height: 24),
            _buildMLPredictionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<weather.WeatherProvider>(
      builder: (context, weatherProvider, _) {
        if (weatherProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final wd = weatherProvider.weatherData;
        if (wd == null) {
          final err = weatherProvider.error;
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  err ?? loc.t('ins_no_weather'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_cloudy, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('ins_weather_title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wd.location.isNotEmpty
                              ? wd.location
                              : loc.t('ins_unknown_location'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          wd.condition,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${wd.temperature.toStringAsFixed(1)}°C',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    context,
                    loc.t('ins_weather_humidity'),
                    '${wd.humidity.toStringAsFixed(0)}%',
                  ),
                  _buildDetailItem(
                    context,
                    loc.t('ins_weather_wind'),
                    '${wd.windSpeed.toStringAsFixed(1)} m/s',
                  ),
                  _buildDetailItem(
                    context,
                    loc.t('ins_weather_updated'),
                    '${wd.timestamp.hour}:${wd.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityChart(
      BuildContext context, List<HistoricalWeatherData> data) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                loc.t('ins_humidity_chart_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final maxHumidity =
                    data.map((e) => e.humidity).reduce((a, b) => a > b ? a : b);
                final maxBarHeight = 150.0;
                final height = maxHumidity > 0
                    ? (item.humidity / maxHumidity) * maxBarHeight
                    : 0.0;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: height > 0 ? height : 2,
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.humidity.toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 11,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateShort(item.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart(
      BuildContext context, List<HistoricalWeatherData> data) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                loc.t('ins_temp_chart_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final maxTemp = data
                    .map((e) => e.temperature)
                    .reduce((a, b) => a > b ? a : b);
                final minTemp = data
                    .map((e) => e.temperature)
                    .reduce((a, b) => a < b ? a : b);
                final range = maxTemp - minTemp;
                final maxBarHeight = 150.0;
                final height = range > 0
                    ? ((item.temperature - minTemp) / range) * maxBarHeight
                    : maxBarHeight / 2;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: height > 0 ? height : 2,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.temperature.toStringAsFixed(1)}°C',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 11,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateShort(item.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<weather.WeatherProvider>(
      builder: (context, wp, _) {
        final List<HistoricalWeatherData> hist =
            wp.historicalWeatherData != null
                ? wp.historicalWeatherData!
                : <HistoricalWeatherData>[];

        if (hist.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('ins_upcoming_weather'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildTemperatureChart(context, hist),
            const SizedBox(height: 16),
            _buildHumidityChart(context, hist),
          ],
        );
      },
    );
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  Widget _buildMLPredictionsSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        final cropsWithPredictions = cropProvider.crops
            .where((crop) => crop.weeklyImages.isNotEmpty)
            .toList();

        if (cropsWithPredictions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.t('ins_no_ml_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.t('ins_no_ml_subtitle'),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('ins_ml_section_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...cropsWithPredictions.map((crop) {
              final latestImage = crop.weeklyImages
                  .where((img) => img.healthPrediction != null)
                  .toList()
                ..sort((a, b) => b.capturedDate.compareTo(a.capturedDate));

              if (latestImage.isEmpty) {
                return const SizedBox.shrink();
              }

              final prediction = latestImage.first.healthPrediction!;
              return _buildPredictionCard(
                context,
                prediction,
                latestImage.first,
                crop.name,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    CropHealthPrediction prediction,
    CropImage cropImage,
    String cropName,
  ) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: prediction.isHealthy
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prediction.isHealthy
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  prediction.isHealthy ? Icons.check_circle : Icons.warning,
                  color: prediction.isHealthy
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      prediction.isHealthy
                          ? loc.t('ins_crop_healthy')
                          : '${loc.t('ins_issue_detected')}: '
                            '${prediction.diseaseType ?? loc.t('ins_unknown_disease')}',
                      style: TextStyle(
                        color: prediction.isHealthy
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (prediction.diseaseType != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${loc.t('ins_disease_label')}: ${prediction.diseaseType}',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            loc.t('ins_care_recommendations'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...prediction.recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${loc.t('ins_image_captured')} '
                '${_formatDateShort(cropImage.capturedDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
