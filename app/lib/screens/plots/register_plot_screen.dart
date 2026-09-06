import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/plot_model.dart';
import '../../providers/plot_provider.dart';
import '../../utils/app_colors.dart';

// 🔹 NEW: localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

// same baseUrl as provider
const String plotBaseUrl =
    kIsWeb ? 'http://localhost:8000' : 'http://192.168.22.159:8000';

class RegisterPlotScreen extends StatefulWidget {
  const RegisterPlotScreen({super.key});

  @override
  State<RegisterPlotScreen> createState() => _RegisterPlotScreenState();
}

class _RegisterPlotScreenState extends State<RegisterPlotScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic plot info
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();

  // 🔹 Area unit options (fixed)
  final List<String> _areaUnitOptions = [
    'acres',
    'hectare',
    'm2',
    'ft2',
    'bigaa',
  ];
  String _selectedAreaUnit = 'acres';

  // Location & address fields
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();

  // lat/lng display
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // Image (land document / plot photo)
  final List<String> _docTypeOptions = [
    'land_deed',
    'registration_certificate',
    'plot_photo',
    'other',
  ];
  String? _selectedDocType;
  XFile? _plotImageFile;
  Uint8List? _plotImageBytes;

  DateTime _selectedRegistrationDate = DateTime.now();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  // 2-step flow state
  String? _createdPlotId;
  bool _isRegistering = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 RegisterPlotScreen.build');

    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('plot_register_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('⬅️ back /crops');
            context.go('/crops');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStepHeader(loc),
              const SizedBox(height: 16),
              _buildBasicInfoSection(loc),
              const SizedBox(height: 16),
              _buildRegistrationDateSelector(loc),
              const SizedBox(height: 16),
              _buildLocationSection(loc),
              const SizedBox(height: 24),
              _buildImageSection(loc),
              const SizedBox(height: 24),
              _buildSubmitButtons(loc),
              _buildErrorBanner(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- STEP HEADER (VISUAL) ----------------

  Widget _buildStepHeader(AppLocalizations loc) {
    final isStep2Active = _createdPlotId != null;

    return Row(
      children: [
        Expanded(
          child: _buildStepChip(
            number: '1',
            label: loc.t('plot_step_info'), // e.g. "Khet ki jankari"
            isActive: true,
            isDone: _createdPlotId != null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStepChip(
            number: '2',
            label: loc.t('plot_step_photo'), // e.g. "Photo / Kagaz"
            isActive: isStep2Active,
            isDone: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStepChip({
    required String number,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final bgColor = isDone
        ? AppColors.success.withOpacity(0.15)
        : isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.grey.shade100;

    final borderColor = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : Colors.grey.shade300;

    final textColor = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isDone
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : Colors.grey.shade400,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI SECTIONS ----------------

  Widget _buildBasicInfoSection(AppLocalizations loc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, size: 22),
                const SizedBox(width: 8),
                Text(
                  loc.t('plot_details_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Plot name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: loc.t('plot_name_label'),
                hintText: loc.t('plot_name_hint'),
                prefixIcon: const Icon(Icons.agriculture),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.t('plot_name_error');
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 🔹 Area value (sirf number)
            TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.t('plot_area_label'),
                hintText: loc.t('plot_area_hint'),
                prefixIcon: const Icon(Icons.straighten),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.t('plot_area_error_empty');
                }
                if (double.tryParse(value) == null) {
                  return loc.t('plot_area_error_invalid');
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            // 🔹 Unit selector label
            Text(
              loc.t('plot_area_unit_label'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            // 🔹 Big, tappable unit chips (acres, hectare, m2, ft2, bigaa)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _areaUnitOptions.map((unit) {
                final isSelected = _selectedAreaUnit == unit;
                return ChoiceChip(
                  label: Text(
                    unit, // exactly: acres, hectare, m2, ft2, bigaa
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedAreaUnit = unit;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 4),

            Text(
              'Selected unit: $_selectedAreaUnit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationDateSelector(AppLocalizations loc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  loc.t('plot_reg_date_label'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectRegistrationDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  '${_selectedRegistrationDate.day}/${_selectedRegistrationDate.month}/${_selectedRegistrationDate.year}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(AppLocalizations loc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                const Icon(Icons.place, size: 22),
                const SizedBox(width: 8),
                Text(
                  loc.t('plot_location_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              loc.t('plot_location_subtitle'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),

            // Big location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _isLoadingLocation
                      ? loc.t('plot_location_getting')
                      : loc.t('plot_location_button'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_currentPosition != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${loc.t('plot_location_captured')} '
                        '${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Lat / Lng (read-only + smaller)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: loc.t('plot_latitude'),
                      prefixIcon: const Icon(Icons.explore),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: loc.t('plot_longitude'),
                      prefixIcon: const Icon(Icons.explore_outlined),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Address fields
            TextFormField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: loc.t('plot_village_label'),
                prefixIcon: const Icon(Icons.location_city),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? loc.t('plot_village_error')
                  : null,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _districtController,
              decoration: InputDecoration(
                labelText: loc.t('plot_district_label'),
                prefixIcon: const Icon(Icons.map),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? loc.t('plot_district_error')
                  : null,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: loc.t('plot_state_label'),
                prefixIcon: const Icon(Icons.flag),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? loc.t('plot_state_error')
                  : null,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: loc.t('plot_country_label'),
                      prefixIcon: const Icon(Icons.public),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? loc.t('plot_country_error')
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.t('plot_pincode_label'),
                      prefixIcon: const Icon(Icons.local_post_office),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: loc.t('plot_address_label'),
                hintText: loc.t('plot_address_hint'),
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? loc.t('plot_address_error')
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(AppLocalizations loc) {
    final isStep2Enabled = _createdPlotId != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title row
            Row(
              children: [
                const Icon(Icons.image, size: 22),
                const SizedBox(width: 8),
                Text(
                  loc.t('plot_image_section_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _createdPlotId == null
                  ? loc.t('plot_image_msg_before')
                  : loc.t('plot_image_msg_after'),
           

              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedDocType,
              decoration: InputDecoration(
                labelText: loc.t('plot_image_type_label'),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _docTypeOptions.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t),
                );
              }).toList(),
              onChanged: (value) {
                debugPrint('🖼️ docType selected=$value');
                setState(() {
                  _selectedDocType = value;
                });
              },
              validator: (value) {
                if (_createdPlotId == null) {
                  return null;
                }
                if (value == null || value.isEmpty) {
                  return loc.t('plot_image_type_error');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isStep2Enabled ? _pickImage : null,
                icon: const Icon(Icons.add_a_photo),
                label: Text(
                  loc.t('plot_select_image_button'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            if (_plotImageBytes != null && _plotImageFile != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        _plotImageBytes!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _plotImageFile!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        debugPrint('🗑️ removing selected image');
                        setState(() {
                          _plotImageFile = null;
                          _plotImageBytes = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButtons(AppLocalizations loc) {
    return Consumer<PlotProvider>(
      builder: (context, plotProvider, _) {
        final bool isInfoBusy = _isRegistering || plotProvider.isLoading;
        final bool canUploadImage =
            _createdPlotId != null && !_isUploadingImage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: isInfoBusy || _createdPlotId != null
                  ? null
                  : _handleRegisterInfo,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: isInfoBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _createdPlotId == null
                          ? loc.t('plot_submit_details_button')
                          : loc.t('plot_details_submitted'),
                    ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: canUploadImage ? _handleUploadImage : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: _isUploadingImage
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(loc.t('plot_upload_image_button')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<PlotProvider>(
      builder: (context, plotProvider, _) {
        if (plotProvider.error == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plotProvider.error!,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- ACTIONS: DATE & LOCATION ----------------

  Future<void> _selectRegistrationDate() async {
    debugPrint('📅 open date picker');
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedRegistrationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      debugPrint('📅 selected=$date');
      setState(() {
        _selectedRegistrationDate = date;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final loc = AppLocalizations.of(context);
    debugPrint('📍 _getCurrentLocation()');
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(loc.t('err_location_services_disabled'));
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(loc.t('err_location_permission_denied'));
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(loc.t('err_location_permission_denied_forever'));
      }

      final position = await Geolocator.getCurrentPosition();
      debugPrint(
          '📍 position lat=${position.latitude}, lng=${position.longitude}');
      _currentPosition = position;

      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);

      await _reverseGeocode(position);
    } catch (e) {
      debugPrint('❌ location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.t('err_getting_location')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _reverseGeocode(Position position) async {
    debugPrint(
        '🌍 reverseGeocode lat=${position.latitude}, lng=${position.longitude}');
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        debugPrint('🌍 no placemarks');
        return;
      }

      final place = placemarks.first;
      debugPrint(
        '🌍 placemark: name=${place.name}, '
        'subLocality=${place.subLocality}, '
        'locality=${place.locality}, '
        'subAdmin=${place.subAdministrativeArea}, '
        'admin=${place.administrativeArea}, '
        'postal=${place.postalCode}, '
        'country=${place.country}',
      );

      _villageController.text = [
        place.subLocality,
        place.locality,
      ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).join(', ');

      _districtController.text = (place.subAdministrativeArea ?? '').isNotEmpty
          ? (place.subAdministrativeArea ?? '')
          : (place.locality ?? '');

      _stateController.text = place.administrativeArea ?? '';
      _countryController.text = place.country ?? '';
      _pincodeController.text = place.postalCode ?? '';

      final parts = <String>[
        place.name ?? '',
        place.subLocality ?? '',
        place.locality ?? '',
        place.subAdministrativeArea ?? '',
        place.administrativeArea ?? '',
        place.postalCode ?? '',
        place.country ?? '',
      ].where((e) => e.isNotEmpty).toList();

      _addressController.text = parts.join(', ');
      debugPrint('📍 full address=${_addressController.text}');
    } catch (e) {
      debugPrint('❌ geocoding error: $e');
    }
  }

  // ---------------- ACTIONS: IMAGE ----------------

  Future<void> _pickImage() async {
    debugPrint('🖼️ _pickImage()');

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      debugPrint('🖼️ image pick cancelled');
      return;
    }

    try {
      final bytes = await picked.readAsBytes();
      setState(() {
        _plotImageFile = picked;
        _plotImageBytes = bytes;
      });
      debugPrint('🖼️ picked file=${picked.name}, bytesLen=${bytes.length}');
    } catch (e) {
      debugPrint('❌ image readAsBytes error: $e');
    }
  }

  // ---------------- STEP 1: REGISTER INFO ----------------

  Future<void> _handleRegisterInfo() async {
    final loc = AppLocalizations.of(context);
    debugPrint('✅ _handleRegisterInfo() called');

    final isValid = _formKey.currentState!.validate();
    debugPrint('✅ form valid=$isValid');
    if (!isValid) return;

    if (_currentPosition == null) {
      debugPrint('⛔ no _currentPosition');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('plot_err_use_location'))),
      );
      return;
    }

    if (_selectedDocType == null || _selectedDocType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('plot_image_type_error'))),
      );
      return;
    }

    final plotProvider = Provider.of<PlotProvider>(context, listen: false);
    final areaValue = double.parse(_areaController.text);

    final plot = Plot(
      id: '',
      farmerId: '1', // backend current_user se lega
      name: _nameController.text.trim(),
      area: areaValue,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _addressController.text.trim(),
      landDocumentUrls: const [],
      registeredDate: _selectedRegistrationDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      additionalData: {
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'land_document_type': _selectedDocType,
        'boundary_coordinates': <List<double>>[],
        // 🔹 NEW: area unit stored along with plot
        'area_unit': _selectedAreaUnit,
      },
    );

    debugPrint('🧱 Plot payload (info step):'
        '\n  name=${plot.name}'
        '\n  area=${plot.area}'
        '\n  areaUnit=$_selectedAreaUnit'
        '\n  addr=${plot.address}'
        '\n  lat=${plot.latitude}, lng=${plot.longitude}'
        '\n  additional=${plot.additionalData}');

    setState(() {
      _isRegistering = true;
    });

    final createdId = await plotProvider.createPlotInfo(plot);

    if (!mounted) return;

    setState(() {
      _isRegistering = false;
      _createdPlotId = createdId;
    });

    debugPrint(
        '📤 createPlotInfo() finished -> plotId=$_createdPlotId, error=${plotProvider.error}');

    if (createdId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('plot_registered_msg')),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loc.t('plot_register_failed')}: ${plotProvider.error ?? loc.t('unknown_error')}',
          ),
        ),
      );
    }
  }

  // ---------------- STEP 2: UPLOAD IMAGE ----------------

  Future<void> _handleUploadImage() async {
    final loc = AppLocalizations.of(context);
    debugPrint('🖼️ _handleUploadImage() called');

    if (_createdPlotId == null) {
      debugPrint('⛔ _createdPlotId is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('plot_err_submit_details_first'))),
      );
      return;
    }

    if (_plotImageFile == null || _plotImageBytes == null) {
      debugPrint('⛔ no image selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('plot_err_select_image'))),
      );
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      debugPrint('🔑 [uploadImage] token=$token, plotId=$_createdPlotId');

      if (token == null || token.isEmpty) {
        throw Exception(loc.t('err_not_authenticated'));
      }

      final uploadUrl =
          '$plotBaseUrl/api/plots/$_createdPlotId/upload-document';

      debugPrint(
          '🔥 [uploadImage] POST $uploadUrl fileName=${_plotImageFile!.name}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'land_doc', // backend: land_doc: UploadFile = File(...)
          _plotImageBytes!,
          filename: _plotImageFile!.name,
        ),
      );

      debugPrint(
          '📤 [uploadImage] filesCount=${request.files.length}, fieldName=land_doc');

      final resp = await request.send();
      final respBody = await resp.stream.bytesToString();

      debugPrint('📩 [uploadImage] status=${resp.statusCode}, body=$respBody');

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception(
          'Upload failed (status: ${resp.statusCode}) body=$respBody',
        );
      }

      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('plot_upload_success'))),
      );

      context.go('/crops');
    } catch (e) {
      debugPrint('❌ [uploadImage.error] $e');
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.t('plot_upload_failed')}: $e')),
      );
    }
  }
}
