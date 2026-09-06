// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../../providers/crop_provider.dart';
// import '../../providers/plot_provider.dart';
// import '../../models/crop_model.dart';
// import '../../models/plot_model.dart';
// import '../../utils/app_colors.dart';

// // 🔹 localization
// import '../../localization/app_localizations.dart';
// import '../../localization/locale_provider.dart';

// class AddCropScreen extends StatefulWidget {
//   const AddCropScreen({super.key});

//   @override
//   State<AddCropScreen> createState() => _AddCropScreenState();
// }

// class _AddCropScreenState extends State<AddCropScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _areaController = TextEditingController();
//   final _addressController = TextEditingController();

//   CropType _selectedCropType = CropType.rice;
//   Plot? _selectedPlot;
//   DateTime _selectedSowingDate = DateTime.now();
//   Position? _currentPosition;
//   bool _isLoadingLocation = false;

//   // 🔹 Area unit options (same fixed list: acres, hectare, m2, ft2, bigaa)
//   final List<String> _areaUnitOptions = [
//     'acres',
//     'hectare',
//     'm2',
//     'ft2',
//     'bigaa',
//   ];
//   String _selectedAreaUnit = 'acres';

//   // 🔹 Season mapping for each crop
//   final Map<CropType, String> _cropSeasonMap = {
//     CropType.rice: 'Kharif',
//     CropType.wheat: 'Rabi',
//     CropType.maize: 'Kharif',
//     CropType.cotton: 'Kharif',
//     CropType.sugarcane: 'Kharif',
//     CropType.potato: 'Rabi',
//     CropType.tomato: 'Zaid',
//     CropType.onion: 'Rabi',
//     CropType.chili: 'Kharif',
//     CropType.other: '—',
//   };

//   String get _currentSeason =>
//       _cropSeasonMap[_selectedCropType] ?? '—';

//   // image state
//   File? _selectedImageFile;
//   Uint8List? _selectedImageBytes;

//   // step state
//   bool _detailsSaved = false;
//   String? _createdCropId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<PlotProvider>().loadPlots();
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _areaController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);
//     final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/crops'),
//         ),
//         title: Text(loc.t('add_crop_title')),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.language),
//             onPressed: () => localeProvider.toggleLocale(),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // 🔹 STEP INDICATOR (same chip style as plot register)
//               _buildStepHeader(loc),
//               const SizedBox(height: 16),

//               // 🔹 DETAILS CARD
//               Card(
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Opacity(
//                     opacity: _detailsSaved ? 0.6 : 1,
//                     child: IgnorePointer(
//                       ignoring: _detailsSaved,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           _buildPlotSelection(context),
//                           const SizedBox(height: 16),

//                           // 🔹 Crop name + auto season
//                           _buildCropTypeSelector(context),

//                           const SizedBox(height: 16),
//                           _buildSowingDateSelector(context),
//                           const SizedBox(height: 16),

//                           // 🔹 Area + unit chips
//                           _buildAreaWithUnitSection(loc),

//                           const SizedBox(height: 16),
//                           _buildLocationSection(context),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // 🔹 IMAGE CARD
//               Card(
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       _buildImageSection(context),
//                       const SizedBox(height: 8),
//                       Text(
//                         _detailsSaved
//                             ? loc.t('add_crop_image_after_details_hint')
//                             : loc.t('add_crop_image_wait_hint'),
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodySmall
//                             ?.copyWith(color: AppColors.textSecondary),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               Consumer<CropProvider>(
//                 builder: (context, cropProvider, _) {
//                   final isLoading = cropProvider.isLoading;

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Button 1: Text API
//                       ElevatedButton.icon(
//                         onPressed: isLoading ? null : _handleSaveDetailsOnly,
//                         icon: const Icon(Icons.description),
//                         label: Text(
//                           _detailsSaved
//                               ? loc.t('add_crop_details_saved_button')
//                               : loc.t('add_crop_save_details_button'),
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Button 2: Image upload API
//                       ElevatedButton.icon(
//                         onPressed: isLoading ? null : _handleUploadImageOnly,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.secondary,
//                         ),
//                         icon: const Icon(Icons.upload),
//                         label: Text(loc.t('add_crop_upload_image_button')),
//                       ),

//                       if (cropProvider.error != null) ...[
//                         const SizedBox(height: 16),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: AppColors.error.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: AppColors.error.withOpacity(0.3),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.error_outline,
//                                 color: AppColors.error,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   cropProvider.error!,
//                                   style: TextStyle(color: AppColors.error),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------- STEP HEADER (same style as RegisterPlot) ----------

//   Widget _buildStepHeader(AppLocalizations loc) {
//     final isStep2Active = _detailsSaved;

//     return Row(
//       children: [
//         Expanded(
//           child: _buildStepChip(
//             number: '1',
//             label: _detailsSaved
//                 ? loc.t('add_crop_step1_done')
//                 : loc.t('add_crop_step1_title'),
//             isActive: true,
//             isDone: _detailsSaved,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _buildStepChip(
//             number: '2',
//             label: loc.t('add_crop_step2_title'),
//             isActive: isStep2Active,
//             isDone: false,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStepChip({
//     required String number,
//     required String label,
//     required bool isActive,
//     required bool isDone,
//   }) {
//     final bgColor = isDone
//         ? AppColors.success.withOpacity(0.15)
//         : isActive
//             ? AppColors.primary.withOpacity(0.1)
//             : Colors.grey.shade100;

//     final borderColor = isDone
//         ? AppColors.success
//         : isActive
//             ? AppColors.primary
//             : Colors.grey.shade300;

//     final textColor = isDone
//         ? AppColors.success
//         : isActive
//             ? AppColors.primary
//             : AppColors.textSecondary;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: borderColor),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 12,
//             backgroundColor: isDone
//                 ? AppColors.success
//                 : isActive
//                     ? AppColors.primary
//                     : Colors.grey.shade400,
//             child: isDone
//                 ? const Icon(Icons.check, size: 14, color: Colors.white)
//                 : Text(
//                     number,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: textColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------- UI PARTS ----------

//   Widget _buildPlotSelection(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Consumer<PlotProvider>(
//       builder: (context, plotProvider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               loc.t('add_crop_select_plot_label'),
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<Plot>(
//               value: _selectedPlot,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.agriculture),
//                 hintText: loc.t('add_crop_select_plot_hint'),
//               ),
//               items: plotProvider.plots.map((plot) {
//                 return DropdownMenuItem(
//                   value: plot,
//                   child: Text(
//                     '${plot.name} (${plot.area.toStringAsFixed(1)} ${loc.t('unit_acres')})',
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedPlot = value;
//                   if (value != null) {
//                     _addressController.text = value.address;
//                     _areaController.text = value.area.toStringAsFixed(2);
//                     _currentPosition = Position(
//                       latitude: value.latitude,
//                       longitude: value.longitude,
//                       timestamp: DateTime.now(),
//                       accuracy: 0,
//                       altitude: 0,
//                       heading: 0,
//                       speed: 0,
//                       speedAccuracy: 0,
//                       altitudeAccuracy: 0,
//                       headingAccuracy: 0,
//                     );
//                   }
//                 });
//               },
//               validator: (value) {
//                 if (value == null) {
//                   return loc.t('add_crop_select_plot_error');
//                 }
//                 return null;
//               },
//             ),
//             if (plotProvider.plots.isEmpty) ...[
//               const SizedBox(height: 8),
//               Text(
//                 loc.t('add_crop_no_plots_text'),
//                 style: TextStyle(color: AppColors.error, fontSize: 12),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton.icon(
//                 onPressed: () => context.go('/register-plot'),
//                 icon: const Icon(Icons.add),
//                 label: Text(loc.t('add_crop_register_plot_button')),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }

//   /// 🔹 Crop dropdown + auto season UI
//   Widget _buildCropTypeSelector(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.t('add_crop_name_label'), // use as "Crop name"
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<CropType>(
//           value: _selectedCropType,
//           decoration: const InputDecoration(
//             prefixIcon: Icon(Icons.spa_outlined),
//           ),
//           items: CropType.values.map((type) {
//             return DropdownMenuItem(
//               value: type,
//               child: Text(_getCropTypeDisplayName(context, type)),
//             );
//           }).toList(),
//           onChanged: (value) {
//             if (value == null) return;
//             setState(() {
//               _selectedCropType = value;
//               // name ko sync rakhenge backend ke liye
//               _nameController.text =
//                   _getCropTypeDisplayName(context, value);
//             });
//           },
//         ),
//         const SizedBox(height: 10),
//         // Season pill (auto)
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.06),
//             borderRadius: BorderRadius.circular(999),
//             border: Border.all(
//               color: AppColors.primary.withOpacity(0.4),
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.wb_sunny_outlined,
//                 size: 18,
//                 color: AppColors.primary,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Season: $_currentSeason (auto)',
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSowingDateSelector(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.t('add_crop_sowing_date_label'),
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: _selectSowingDate,
//           child: InputDecorator(
//             decoration: const InputDecoration(
//               prefixIcon: Icon(Icons.calendar_today),
//             ),
//             child: Text(
//               '${_selectedSowingDate.day}/${_selectedSowingDate.month}/${_selectedSowingDate.year}',
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // 🔹 Area + unit chips (UX enhanced)
//   Widget _buildAreaWithUnitSection(AppLocalizations loc) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Area value field
//         TextFormField(
//           controller: _areaController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             labelText: loc.t('add_crop_area_label'),
//             hintText: loc.t('add_crop_area_hint'),
//             prefixIcon: const Icon(Icons.straighten),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return loc.t('add_crop_area_error_empty');
//             }
//             if (double.tryParse(value) == null) {
//               return loc.t('add_crop_area_error_invalid');
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 10),
//         Text(
//           // reuse same label as plot to avoid extra l10n key
//           loc.t('plot_area_unit_label'),
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: _areaUnitOptions.map((unit) {
//             final isSelected = _selectedAreaUnit == unit;
//             return ChoiceChip(
//               label: Text(
//                 unit, // exactly these: acres, hectare, m2, ft2, bigaa
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: isSelected ? Colors.white : AppColors.textPrimary,
//                 ),
//               ),
//               selected: isSelected,
//               selectedColor: AppColors.primary,
//               backgroundColor: Colors.grey.shade100,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 side: BorderSide(
//                   color:
//                       isSelected ? AppColors.primary : Colors.grey.shade300,
//                 ),
//               ),
//               onSelected: (_) {
//                 setState(() {
//                   _selectedAreaUnit = unit;
//                 });
//               },
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Selected unit: $_selectedAreaUnit',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationSection(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.t('add_crop_location_label'),
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _addressController,
//           maxLines: 2,
//           decoration: InputDecoration(
//             labelText: loc.t('add_crop_farm_address_label'),
//             hintText: loc.t('add_crop_farm_address_hint'),
//             prefixIcon: const Icon(Icons.location_on),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return loc.t('add_crop_farm_address_error');
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: _isLoadingLocation ? null : _getCurrentLocation,
//                 icon: _isLoadingLocation
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.my_location),
//                 label: Text(
//                   _isLoadingLocation
//                       ? loc.t('add_crop_getting_location')
//                       : loc.t('add_crop_get_location_button'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         if (_currentPosition != null) ...[
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.success.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: AppColors.success.withOpacity(0.3),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle,
//                     color: AppColors.success, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     '${loc.t('add_crop_location_prefix')} '
//                     '${_currentPosition!.latitude.toStringAsFixed(4)}, '
//                     '${_currentPosition!.longitude.toStringAsFixed(4)}',
//                     style: TextStyle(color: AppColors.success),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildImageSection(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.t('add_crop_image_label'),
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: _detailsSaved ? _pickImage : null,
//           child: Container(
//             height: 200,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _detailsSaved
//                     ? AppColors.border
//                     : AppColors.border.withOpacity(0.5),
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: _selectedImageBytes != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.memory(
//                       _selectedImageBytes!,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : _selectedImageFile != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.file(
//                           _selectedImageFile!,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.add_a_photo,
//                             size: 48,
//                             color: AppColors.textSecondary,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             loc.t('add_crop_image_hint'),
//                             style:
//                                 TextStyle(color: AppColors.textSecondary),
//                           ),
//                         ],
//                       ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ---------- LOGIC PART ----------

//   Future<void> _pickImage() async {
//     final loc = AppLocalizations.of(context);

//     if (!_detailsSaved) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_save_details_first')),
//         ),
//       );
//       return;
//     }

//     if (!kIsWeb) {
//       final status = await Permission.camera.request();
//       if (!status.isGranted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               loc.t('add_crop_camera_permission_error'),
//             ),
//           ),
//         );
//         return;
//       }
//     }

//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         if (kIsWeb) {
//           final bytes = await pickedFile.readAsBytes();
//           setState(() {
//             _selectedImageBytes = bytes;
//             _selectedImageFile = null;
//           });
//         } else {
//           setState(() {
//             _selectedImageFile = File(pickedFile.path);
//             _selectedImageBytes = null;
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${loc.t('add_crop_camera_open_error')}: $e'),
//         ),
//       );
//     }
//   }

//   Future<void> _selectSowingDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedSowingDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//     );

//     if (date != null) {
//       setState(() {
//         _selectedSowingDate = date;
//       });
//     }
//   }

//   String _getCropTypeDisplayName(BuildContext context, CropType type) {
//     final loc = AppLocalizations.of(context);

//     switch (type) {
//       case CropType.rice:
//         return loc.t('crop_type_rice');
//       case CropType.wheat:
//         return loc.t('crop_type_wheat');
//       case CropType.maize:
//         return loc.t('crop_type_maize');
//       case CropType.cotton:
//         return loc.t('crop_type_cotton');
//       case CropType.sugarcane:
//         return loc.t('crop_type_sugarcane');
//       case CropType.potato:
//         return loc.t('crop_type_potato');
//       case CropType.tomato:
//         return loc.t('crop_type_tomato');
//       case CropType.onion:
//         return loc.t('crop_type_onion');
//       case CropType.chili:
//         return loc.t('crop_type_chili');
//       case CropType.other:
//         return loc.t('crop_type_other');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     final loc = AppLocalizations.of(context);

//     setState(() {
//       _isLoadingLocation = true;
//     });

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception(loc.t('add_crop_location_service_disabled'));
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception(
//             loc.t('add_crop_location_permission_denied'),
//           );
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception(
//           loc.t('add_crop_location_permission_denied_forever'),
//         );
//       }

//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _currentPosition = position;
//         _isLoadingLocation = false;
//       });

//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );
//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks[0];
//           _addressController.text =
//               '${place.locality}, ${place.administrativeArea}, ${place.country}';
//         }
//       } catch (e) {
//         debugPrint('Error getting address: $e');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${loc.t('add_crop_location_error')}: $e'),
//         ),
//       );
//     }
//   }

//   /// Button 1 → STEP-1 (TEXT API)
//   Future<void> _handleSaveDetailsOnly() async {
//     final loc = AppLocalizations.of(context);

//     if (_detailsSaved) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_already_saved')),
//         ),
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedPlot == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_submit_missing_plot')),
//         ),
//       );
//       return;
//     }

//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_submit_missing_location')),
//         ),
//       );
//       return;
//     }

//     // name ko dropdown ke hisaab se set kar rahe hain
//     final cropName = _getCropTypeDisplayName(context, _selectedCropType);
//     _nameController.text = cropName;

//     final cropProvider =
//         Provider.of<CropProvider>(context, listen: false);

//     final crop = Crop(
//       id: '',
//       farmerId: '1', // TODO: auth se lao
//       plotId: _selectedPlot!.id,
//       name: cropName,
//       type: _selectedCropType,
//       sowingDate: _selectedSowingDate,
//       area: double.parse(_areaController.text),
//       latitude: _currentPosition!.latitude,
//       longitude: _currentPosition!.longitude,
//       address: _addressController.text.trim(),
//       imageUrl: null,
//       currentStage: CropStage.sowing,
//       weeklyImages: const [],
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       // season agar backend me chahiye ho to Crop model me extra field add kar sakte ho
//       // yahan mapping already ready hai: _currentSeason
//     );

//     FocusScope.of(context).unfocus();

//     final cropId = await cropProvider.createCropTextOnly(crop);

//     if (cropId != null && mounted) {
//       setState(() {
//         _detailsSaved = true;
//         _createdCropId = cropId;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_details_saved_snackbar')),
//         ),
//       );
//     }
//   }

//   /// Button 2 → STEP-2 (IMAGE API)
//   Future<void> _handleUploadImageOnly() async {
//     final loc = AppLocalizations.of(context);

//     if (!_detailsSaved || _createdCropId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_save_details_first')),
//         ),
//       );
//       return;
//     }

//     if (_selectedImageBytes == null && _selectedImageFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_image_required')),
//         ),
//       );
//       return;
//     }

//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_submit_missing_location')),
//         ),
//       );
//       return;
//     }

//     final cropProvider =
//         Provider.of<CropProvider>(context, listen: false);

//     final ok = await cropProvider.uploadInitialImage(
//       cropId: _createdCropId!,
//       imageBytes: _selectedImageBytes,
//       filePath: _selectedImageFile?.path,
//       lat: _currentPosition!.latitude,
//       lng: _currentPosition!.longitude,
//     );

//     if (ok && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(loc.t('add_crop_submit_success')),
//         ),
//       );
//       context.go('/crops');
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../providers/crop_provider.dart';
import '../../providers/plot_provider.dart';
import '../../models/crop_model.dart';
import '../../models/plot_model.dart';
import '../../utils/app_colors.dart';

// 🔹 localization
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();

  CropType _selectedCropType = CropType.rice;
  Plot? _selectedPlot;
  DateTime _selectedSowingDate = DateTime.now();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  // 🔹 Area unit options (same fixed list: acres, hectare, m2, ft2, bigaa)
  final List<String> _areaUnitOptions = [
    'acres',
    'hectare',
    'm2',
    'ft2',
    'bigaa',
  ];
  String _selectedAreaUnit = 'acres';

  // 🔹 Season mapping for each crop
  final Map<CropType, String> _cropSeasonMap = {
    CropType.rice: 'Kharif',
    CropType.wheat: 'Rabi',
    CropType.maize: 'Kharif',
    CropType.cotton: 'Kharif',
    CropType.sugarcane: 'Kharif',
    CropType.potato: 'Rabi',
    CropType.tomato: 'Zaid',
    CropType.onion: 'Rabi',
    CropType.chili: 'Kharif',
    CropType.other: '—',
  };

  String get _currentSeason => _cropSeasonMap[_selectedCropType] ?? '—';

  // image state
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  // step state
  bool _detailsSaved = false;
  String? _createdCropId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlotProvider>().loadPlots();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/crops'),
        ),
        title: Text(loc.t('add_crop_title')),
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
              // 🔹 STEP INDICATOR (same chip style as plot register)
              _buildStepHeader(loc),
              const SizedBox(height: 16),

              // 🔹 DETAILS CARD
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Opacity(
                    opacity: _detailsSaved ? 0.6 : 1,
                    child: IgnorePointer(
                      ignoring: _detailsSaved,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPlotSelection(context),
                          const SizedBox(height: 16),

                          // 🔹 Crop name + auto season
                          _buildCropTypeSelector(context),

                          const SizedBox(height: 16),
                          _buildSowingDateSelector(context),
                          const SizedBox(height: 16),

                          // 🔹 Area + unit chips
                          _buildAreaWithUnitSection(loc),

                          const SizedBox(height: 16),
                          _buildLocationSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 IMAGE CARD
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageSection(context),
                      const SizedBox(height: 8),
                      Text(
                        _detailsSaved
                            ? loc.t('add_crop_image_after_details_hint')
                            : loc.t('add_crop_image_wait_hint'),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Consumer<CropProvider>(
                builder: (context, cropProvider, _) {
                  final isLoading = cropProvider.isLoading;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Button 1: Text API
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleSaveDetailsOnly,
                        icon: const Icon(Icons.description),
                        label: Text(
                          _detailsSaved
                              ? loc.t('add_crop_details_saved_button')
                              : loc.t('add_crop_save_details_button'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Button 2: Image upload API
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleUploadImageOnly,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        icon: const Icon(Icons.upload),
                        label: Text(loc.t('add_crop_upload_image_button')),
                      ),

                      if (cropProvider.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
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
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cropProvider.error!,
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- STEP HEADER (same style as RegisterPlot) ----------

  Widget _buildStepHeader(AppLocalizations loc) {
    final isStep2Active = _detailsSaved;

    return Row(
      children: [
        Expanded(
          child: _buildStepChip(
            number: '1',
            label: _detailsSaved
                ? loc.t('add_crop_step1_done')
                : loc.t('add_crop_step1_title'),
            isActive: true,
            isDone: _detailsSaved,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStepChip(
            number: '2',
            label: loc.t('add_crop_step2_title'),
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

  // ---------- UI PARTS ----------

  Widget _buildPlotSelection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<PlotProvider>(
      builder: (context, plotProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('add_crop_select_plot_label'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Plot>(
              value: _selectedPlot,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.agriculture),
                hintText: loc.t('add_crop_select_plot_hint'),
              ),
              items: plotProvider.plots.map((plot) {
                return DropdownMenuItem(
                  value: plot,
                  child: Text(
                    '${plot.name} (${plot.area.toStringAsFixed(1)} ${loc.t('unit_acres')})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlot = value;
                  if (value != null) {
                    _addressController.text = value.address;
                    _areaController.text = value.area.toStringAsFixed(2);
                    _currentPosition = Position(
                      latitude: value.latitude,
                      longitude: value.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    );
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return loc.t('add_crop_select_plot_error');
                }
                return null;
              },
            ),
            if (plotProvider.plots.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                loc.t('add_crop_no_plots_text'),
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => context.go('/register-plot'),
                icon: const Icon(Icons.add),
                label: Text(loc.t('add_crop_register_plot_button')),
              ),
            ],
          ],
        );
      },
    );
  }

  /// 🔹 Crop dropdown + auto season UI
  Widget _buildCropTypeSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('add_crop_name_label'), // use as "Crop name"
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CropType>(
          value: _selectedCropType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.spa_outlined),
          ),
          items: CropType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getCropTypeDisplayName(context, type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedCropType = value;
              // name ko sync rakhenge backend ke liye
              _nameController.text = _getCropTypeDisplayName(context, value);
            });
          },
        ),
        const SizedBox(height: 10),
        // Season pill (auto)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Season: $_currentSeason (auto)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSowingDateSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('add_crop_sowing_date_label'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectSowingDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_selectedSowingDate.day}/${_selectedSowingDate.month}/${_selectedSowingDate.year}',
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Area + unit chips (UX enhanced)
  Widget _buildAreaWithUnitSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Area value field
        TextFormField(
          controller: _areaController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.t('add_crop_area_label'),
            hintText: loc.t('add_crop_area_hint'),
            prefixIcon: const Icon(Icons.straighten),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return loc.t('add_crop_area_error_empty');
            }
            if (double.tryParse(value) == null) {
              return loc.t('add_crop_area_error_invalid');
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Text(
          // reuse same label as plot to avoid extra l10n key
          loc.t('plot_area_unit_label'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _areaUnitOptions.map((unit) {
            final isSelected = _selectedAreaUnit == unit;
            return ChoiceChip(
              label: Text(
                unit, // exactly these: acres, hectare, m2, ft2, bigaa
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
                  color:
                      isSelected ? AppColors.primary : Colors.grey.shade300,
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
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('add_crop_location_label'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: loc.t('add_crop_farm_address_label'),
            hintText: loc.t('add_crop_farm_address_hint'),
            prefixIcon: const Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return loc.t('add_crop_farm_address_error');
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _isLoadingLocation
                      ? loc.t('add_crop_getting_location')
                      : loc.t('add_crop_get_location_button'),
                ),
              ),
            ),
          ],
        ),
        if (_currentPosition != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
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
                    '${loc.t('add_crop_location_prefix')} '
                    '${_currentPosition!.latitude.toStringAsFixed(4)}, '
                    '${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('add_crop_image_label'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _detailsSaved ? _pickImage : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _detailsSaved
                    ? AppColors.border
                    : AppColors.border.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.t('add_crop_image_hint'),
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  // ---------- LOGIC PART ----------

  /// now only gallery upload, no camera / permission
  Future<void> _pickImage() async {
    final loc = AppLocalizations.of(context);

    if (!_detailsSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_save_details_first')),
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();

      // gallery se image pick karega
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageFile = null;
          });
        } else {
          setState(() {
            _selectedImageFile = File(pickedFile.path);
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.t('add_crop_camera_open_error')}: $e'),
        ),
      );
    }
  }

  Future<void> _selectSowingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedSowingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedSowingDate = date;
      });
    }
  }

  String _getCropTypeDisplayName(BuildContext context, CropType type) {
    final loc = AppLocalizations.of(context);

    switch (type) {
      case CropType.rice:
        return loc.t('crop_type_rice');
      case CropType.wheat:
        return loc.t('crop_type_wheat');
      case CropType.maize:
        return loc.t('crop_type_maize');
      case CropType.cotton:
        return loc.t('crop_type_cotton');
      case CropType.sugarcane:
        return loc.t('crop_type_sugarcane');
      case CropType.potato:
        return loc.t('crop_type_potato');
      case CropType.tomato:
        return loc.t('crop_type_tomato');
      case CropType.onion:
        return loc.t('crop_type_onion');
      case CropType.chili:
        return loc.t('crop_type_chili');
      case CropType.other:
        return loc.t('crop_type_other');
    }
  }

  Future<void> _getCurrentLocation() async {
    final loc = AppLocalizations.of(context);

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(loc.t('add_crop_location_service_disabled'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            loc.t('add_crop_location_permission_denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          loc.t('add_crop_location_permission_denied_forever'),
        );
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _addressController.text =
              '${place.locality}, ${place.administrativeArea}, ${place.country}';
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.t('add_crop_location_error')}: $e'),
        ),
      );
    }
  }

  /// Button 1 → STEP-1 (TEXT API)
  Future<void> _handleSaveDetailsOnly() async {
    final loc = AppLocalizations.of(context);

    if (_detailsSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_already_saved')),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_submit_missing_plot')),
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_submit_missing_location')),
        ),
      );
      return;
    }

    // name ko dropdown ke hisaab se set kar rahe hain
    final cropName = _getCropTypeDisplayName(context, _selectedCropType);
    _nameController.text = cropName;

    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    final crop = Crop(
      id: '',
      farmerId: '1', // TODO: auth se lao
      plotId: _selectedPlot!.id,
      name: cropName,
      type: _selectedCropType,
      sowingDate: _selectedSowingDate,
      area: double.parse(_areaController.text),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _addressController.text.trim(),
      imageUrl: null,
      currentStage: CropStage.sowing,
      weeklyImages: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // season agar backend me chahiye ho to Crop model me extra field add kar sakte ho
      // yahan mapping already ready hai: _currentSeason
    );

    FocusScope.of(context).unfocus();

    final cropId = await cropProvider.createCropTextOnly(crop);

    if (cropId != null && mounted) {
      setState(() {
        _detailsSaved = true;
        _createdCropId = cropId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_details_saved_snackbar')),
        ),
      );
    }
  }

  /// Button 2 → STEP-2 (IMAGE API)
  Future<void> _handleUploadImageOnly() async {
    final loc = AppLocalizations.of(context);

    if (!_detailsSaved || _createdCropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_save_details_first')),
        ),
      );
      return;
    }

    if (_selectedImageBytes == null && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_image_required')),
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_submit_missing_location')),
        ),
      );
      return;
    }

    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    final ok = await cropProvider.uploadInitialImage(
      cropId: _createdCropId!,
      imageBytes: _selectedImageBytes,
      filePath: _selectedImageFile?.path,
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('add_crop_submit_success')),
        ),
      );
      context.go('/crops');
    }
  }
}
