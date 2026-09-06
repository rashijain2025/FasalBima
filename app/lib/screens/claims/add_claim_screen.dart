// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../providers/claim_provider.dart';
// import '../../providers/crop_provider.dart';
// import '../../models/claim_model.dart';
// import '../../models/crop_model.dart';
// import '../../utils/app_colors.dart';

// class AddClaimScreen extends StatefulWidget {
//   const AddClaimScreen({super.key});

//   @override
//   State<AddClaimScreen> createState() => _AddClaimScreenState();
// }

// class _AddClaimScreenState extends State<AddClaimScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _descriptionController = TextEditingController();
//   final _estimatedLossController = TextEditingController();
//   final _estimatedValueController = TextEditingController();

//   Crop? _selectedCrop;
//   DisasterType _selectedDisasterType = DisasterType.flood;
//   DateTime _selectedDisasterDate = DateTime.now();
//   List<XFile> _selectedImages = [];
//   List<Uint8List> _selectedImageBytes = [];

//   String? _createdClaimId;
//   bool _isRegistering = false;
//   bool _isUploadingEvidence = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CropProvider>().loadCrops();
//     });
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _estimatedLossController.dispose();
//     _estimatedValueController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final claimProvider = context.watch<ClaimProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/claims'),
//         ),
//         title: const Text('Report Crop Loss'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Description
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   hintText: 'Describe the damage and its impact',
//                   prefixIcon: Icon(Icons.description),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Disaster Type
//               _buildDisasterTypeSelector(),
//               const SizedBox(height: 16),

//               // Crop Selection
//               _buildCropSelection(),
//               const SizedBox(height: 24),

//               // Disaster Date
//               _buildDisasterDateSelector(),
//               const SizedBox(height: 16),

//               // Estimated Loss
//               TextFormField(
//                 controller: _estimatedLossController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Estimated Loss (%)',
//                   hintText: 'e.g., 50',
//                   prefixIcon: Icon(Icons.trending_down),
//                   suffixText: '%',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter estimated loss';
//                   }
//                   final loss = double.tryParse(value);
//                   if (loss == null || loss < 0 || loss > 100) {
//                     return 'Please enter a valid percentage (0-100)';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Estimated Value
//               TextFormField(
//                 controller: _estimatedValueController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Estimated Value Loss (₹)',
//                   hintText: 'e.g., 50000',
//                   prefixIcon: Icon(Icons.attach_money),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter estimated value loss';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid amount';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // ========= 1️⃣ SUBMIT BUTTON BEFORE DAMAGE EVIDENCE =========
//               ElevatedButton(
//                 onPressed: (_isRegistering ||
//                         claimProvider.isLoading ||
//                         _createdClaimId != null)
//                     ? null
//                     : _handleRegisterClaim,
//                 child: (_isRegistering || claimProvider.isLoading)
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : Text(
//                         _createdClaimId == null
//                             ? 'Submit Claim Details'
//                             : 'Claim Submitted',
//                       ),
//               ),

//               const SizedBox(height: 24),

//               // ========= 2️⃣ DAMAGE EVIDENCE SECTION =========
//               _buildImagesSection(),
//               const SizedBox(height: 12),

//               // Upload Evidence Button (uses claimId)
//               ElevatedButton(
//                 onPressed: (_createdClaimId == null || _isUploadingEvidence)
//                     ? null
//                     : _handleUploadEvidence,
//                 child: _isUploadingEvidence
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : const Text('Upload Damage Evidence'),
//               ),

//               // Error Message from ClaimProvider
//               if (claimProvider.error != null)
//                 Container(
//                   margin: const EdgeInsets.only(top: 16),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.error.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: AppColors.error.withValues(alpha: 0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         color: AppColors.error,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           claimProvider.error!,
//                           style: TextStyle(color: AppColors.error),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCropSelection() {
//     return Consumer<CropProvider>(
//       builder: (context, cropProvider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select Crop',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<Crop>(
//               value: _selectedCrop,
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.agriculture),
//                 hintText: 'Select the affected crop',
//               ),
//               items: cropProvider.crops.map((crop) {
//                 return DropdownMenuItem(
//                   value: crop,
//                   child: Text('${crop.name} (${crop.typeDisplayName})'),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCrop = value;
//                 });
//               },
//               validator: (value) {
//                 if (value == null) {
//                   return 'Please select a crop';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildDisasterTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Disaster Type',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<DisasterType>(
//           value: _selectedDisasterType,
//           decoration: const InputDecoration(
//             prefixIcon: Icon(Icons.warning),
//           ),
//           items: DisasterType.values.map((type) {
//             return DropdownMenuItem(
//               value: type,
//               child: Text(_getDisasterTypeDisplayName(type)),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedDisasterType = value!;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDisasterDateSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Disaster Date',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: _selectDisasterDate,
//           child: InputDecorator(
//             decoration: const InputDecoration(
//               prefixIcon: Icon(Icons.calendar_today),
//             ),
//             child: Text(
//               '${_selectedDisasterDate.day}/${_selectedDisasterDate.month}/${_selectedDisasterDate.year}',
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImagesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Damage Evidence (Photos)',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _createdClaimId == null
//               ? 'First submit claim details, then upload damage photos.'
//               : 'Upload photos showing the damage to your crops.',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           onPressed: _createdClaimId == null ? null : _pickImages,
//           icon: const Icon(Icons.add_a_photo),
//           label: const Text('Add Photos'),
//         ),
//         if (_selectedImages.isNotEmpty) ...[
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _selectedImages.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   child: Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.memory(
//                           index < _selectedImageBytes.length
//                               ? _selectedImageBytes[index]
//                               : Uint8List(0),
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                         top: 4,
//                         right: 4,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedImages.removeAt(index);
//                               if (index < _selectedImageBytes.length) {
//                                 _selectedImageBytes.removeAt(index);
//                               }
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Future<void> _selectDisasterDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDisasterDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//     );

//     if (date != null) {
//       setState(() {
//         _selectedDisasterDate = date;
//       });
//     }
//   }

//   Future<void> _pickImages() async {
//     final picker = ImagePicker();
//     final pickedFiles = await picker.pickMultiImage();
//     if (pickedFiles.isNotEmpty) {
//       final bytesList = <Uint8List>[];
//       for (final f in pickedFiles) {
//         try {
//           final b = await f.readAsBytes();
//           bytesList.add(b);
//         } catch (_) {
//           bytesList.add(Uint8List(0));
//         }
//       }
//       setState(() {
//         _selectedImages.addAll(pickedFiles);
//         _selectedImageBytes.addAll(bytesList);
//       });
//       debugPrint("🖼️ [_pickImages] selectedCount=${_selectedImages.length}");
//     }
//   }

//   String _getDisasterTypeDisplayName(DisasterType type) {
//     switch (type) {
//       case DisasterType.flood:
//         return 'Flood';
//       case DisasterType.drought:
//         return 'Drought';
//       case DisasterType.pestAttack:
//         return 'Pest Attack';
//       case DisasterType.disease:
//         return 'Disease';
//       case DisasterType.hailstorm:
//         return 'Hailstorm';
//       case DisasterType.cyclone:
//         return 'Cyclone';
//       case DisasterType.fire:
//         return 'Fire';
//       case DisasterType.other:
//         return 'Other';
//     }
//   }

//   // STEP 1: register claim
//   Future<void> _handleRegisterClaim() async {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     if (!isValid) return;

//     if (_selectedCrop == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a crop')),
//       );
//       return;
//     }

//     final claimProvider = context.read<ClaimProvider>();

//     setState(() {
//       _isRegistering = true;
//     });

//     final claim = Claim(
//       id: '',
//       farmerId: '',
//       cropId: _selectedCrop!.id,
//       disasterType: _selectedDisasterType,
//       description: _descriptionController.text.trim(),
//       estimatedLoss: double.tryParse(_estimatedLossController.text) ?? 0.0,
//       estimatedValue: double.tryParse(_estimatedValueController.text) ?? 0.0,
//       imageUrls: const [],
//       status: ClaimStatus.underReview,
//       disasterDate: _selectedDisasterDate,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );

//     final beforeCount = claimProvider.claims.length;
//     debugPrint("ℹ️ [_handleRegisterClaim] beforeCount=$beforeCount");

//     bool success = false;

//     try {
//       success = await claimProvider.addClaim(claim);
//     } catch (e) {
//       debugPrint('❌ register claim error: $e');
//       success = false;
//     }

//     if (!mounted) return;

//     setState(() {
//       _isRegistering = false;
//     });

//     final afterCount = claimProvider.claims.length;
//     debugPrint("ℹ️ [_handleRegisterClaim] afterCount=$afterCount");

//     if (success) {
//       Claim? newClaim;
//       if (afterCount > beforeCount) {
//         newClaim = claimProvider.claims.last;
//       }

//       setState(() {
//         _createdClaimId = newClaim?.id;
//       });

//       debugPrint("✅ [_handleRegisterClaim] createdClaimId=${_createdClaimId}");

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             _createdClaimId != null
//                 ? 'Claim registered! Now upload damage evidence.'
//                 : 'Claim registered (id not fetched, but registered).',
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             claimProvider.error ?? 'Failed to register claim',
//           ),
//         ),
//       );
//     }
//   }

//   // STEP 2: upload evidence using provider
//   Future<void> _handleUploadEvidence() async {
//     if (_createdClaimId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please submit claim details first')),
//       );
//       return;
//     }

//     if (_selectedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add at least one image')),
//       );
//       return;
//     }

//     final claimProvider = context.read<ClaimProvider>();

//     setState(() {
//       _isUploadingEvidence = true;
//     });

//     debugPrint(
//       "🔥 [_handleUploadEvidence] claimId=$_createdClaimId, files=${_selectedImages.length}",
//     );

//     bool success = false;
//     try {
//       success = await claimProvider.uploadEvidence(
//         _createdClaimId!,
//         _selectedImages,
//       );
//     } catch (e) {
//       debugPrint('❌ upload evidence error: $e');
//       success = false;
//     }

//     if (!mounted) return;

//     setState(() {
//       _isUploadingEvidence = false;
//     });

//     if (success) {
//       debugPrint(
//           "✅ [_handleUploadEvidence] evidence upload success for claimId=$_createdClaimId");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Evidence uploaded successfully!')),
//       );
//       context.go('/claims');
//     } else {
//       debugPrint(
//           "❌ [_handleUploadEvidence] evidence upload failed, error=${claimProvider.error}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             claimProvider.error ?? 'Failed to upload evidence',
//           ),
//         ),
//       );
//     }
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/claim_provider.dart';
import '../../providers/crop_provider.dart';
import '../../models/claim_model.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';

// 🔹 NEW: localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class AddClaimScreen extends StatefulWidget {
  const AddClaimScreen({super.key});

  @override
  State<AddClaimScreen> createState() => _AddClaimScreenState();
}

class _AddClaimScreenState extends State<AddClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _estimatedLossController = TextEditingController();
  final _estimatedValueController = TextEditingController();

  Crop? _selectedCrop;
  DisasterType _selectedDisasterType = DisasterType.flood;
  DateTime _selectedDisasterDate = DateTime.now();
  List<XFile> _selectedImages = [];
  List<Uint8List> _selectedImageBytes = [];

  String? _createdClaimId;
  bool _isRegistering = false;
  bool _isUploadingEvidence = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadCrops();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedLossController.dispose();
    _estimatedValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimProvider = context.watch<ClaimProvider>();
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/claims'),
        ),
        title: Text(loc.t('claim_title')),
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
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.t('claim_description_label'),
                  hintText: loc.t('claim_description_hint'),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('claim_error_description_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Disaster Type
              _buildDisasterTypeSelector(context),
              const SizedBox(height: 16),

              // Crop Selection
              _buildCropSelection(context),
              const SizedBox(height: 24),

              // Disaster Date
              _buildDisasterDateSelector(context),
              const SizedBox(height: 16),

              // Estimated Loss
              TextFormField(
                controller: _estimatedLossController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.t('claim_est_loss_label'),
                  hintText: loc.t('claim_est_loss_hint'),
                  prefixIcon: const Icon(Icons.trending_down),
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('claim_error_est_loss_required');
                  }
                  final loss = double.tryParse(value);
                  if (loss == null || loss < 0 || loss > 100) {
                    return loc.t('claim_error_est_loss_range');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Estimated Value
              TextFormField(
                controller: _estimatedValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.t('claim_est_value_label'),
                  hintText: loc.t('claim_est_value_hint'),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('claim_error_est_value_required');
                  }
                  if (double.tryParse(value) == null) {
                    return loc.t('claim_error_est_value_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ========= 1️⃣ SUBMIT BUTTON BEFORE DAMAGE EVIDENCE =========
              ElevatedButton(
                onPressed: (_isRegistering ||
                        claimProvider.isLoading ||
                        _createdClaimId != null)
                    ? null
                    : _handleRegisterClaim,
                child: (_isRegistering || claimProvider.isLoading)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _createdClaimId == null
                            ? loc.t('claim_submit_details')
                            : loc.t('claim_details_submitted'),
                      ),
              ),

              const SizedBox(height: 24),

              // ========= 2️⃣ DAMAGE EVIDENCE SECTION =========
              _buildImagesSection(context),
              const SizedBox(height: 12),

              // Upload Evidence Button (uses claimId)
              ElevatedButton(
                onPressed: (_createdClaimId == null || _isUploadingEvidence)
                    ? null
                    : _handleUploadEvidence,
                child: _isUploadingEvidence
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(loc.t('claim_upload_evidence_button')),
              ),

              // Error Message from ClaimProvider
              if (claimProvider.error != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
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
                          claimProvider.error!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropSelection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('claim_select_crop_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Crop>(
              value: _selectedCrop,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.agriculture),
                hintText: loc.t('claim_select_crop_hint'),
              ),
              items: cropProvider.crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text('${crop.name} (${crop.typeDisplayName})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return loc.t('claim_error_crop_required');
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisasterTypeSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('claim_disaster_type_title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DisasterType>(
          value: _selectedDisasterType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.warning),
          ),
          items: DisasterType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getDisasterTypeDisplayName(context, type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDisasterType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDisasterDateSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('claim_disaster_date_title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDisasterDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_selectedDisasterDate.day}/${_selectedDisasterDate.month}/${_selectedDisasterDate.year}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('claim_evidence_title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _createdClaimId == null
              ? loc.t('claim_evidence_info_before')
              : loc.t('claim_evidence_info_after'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _createdClaimId == null ? null : _pickImages,
          icon: const Icon(Icons.add_a_photo),
          label: Text(loc.t('claim_add_photos_button')),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          index < _selectedImageBytes.length
                              ? _selectedImageBytes[index]
                              : Uint8List(0),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                              if (index < _selectedImageBytes.length) {
                                _selectedImageBytes.removeAt(index);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDisasterDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDisasterDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDisasterDate = date;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final bytesList = <Uint8List>[];
      for (final f in pickedFiles) {
        try {
          final b = await f.readAsBytes();
          bytesList.add(b);
        } catch (_) {
          bytesList.add(Uint8List(0));
        }
      }
      setState(() {
        _selectedImages.addAll(pickedFiles);
        _selectedImageBytes.addAll(bytesList);
      });
      debugPrint("🖼️ [_pickImages] selectedCount=${_selectedImages.length}");
    }
  }

  String _getDisasterTypeDisplayName(BuildContext context, DisasterType type) {
    final loc = AppLocalizations.of(context);

    switch (type) {
      case DisasterType.flood:
        return loc.t('disaster_flood');
      case DisasterType.drought:
        return loc.t('disaster_drought');
      case DisasterType.pestAttack:
        return loc.t('disaster_pest_attack');
      case DisasterType.disease:
        return loc.t('disaster_disease');
      case DisasterType.hailstorm:
        return loc.t('disaster_hailstorm');
      case DisasterType.cyclone:
        return loc.t('disaster_cyclone');
      case DisasterType.fire:
        return loc.t('disaster_fire');
      case DisasterType.other:
        return loc.t('disaster_other');
    }
  }

  // STEP 1: register claim
  Future<void> _handleRegisterClaim() async {
    final loc = AppLocalizations.of(context);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('claim_error_crop_required_snack'))),
      );
      return;
    }

    final claimProvider = context.read<ClaimProvider>();

    setState(() {
      _isRegistering = true;
    });

    final claim = Claim(
      id: '',
      farmerId: '',
      cropId: _selectedCrop!.id,
      disasterType: _selectedDisasterType,
      description: _descriptionController.text.trim(),
      estimatedLoss: double.tryParse(_estimatedLossController.text) ?? 0.0,
      estimatedValue: double.tryParse(_estimatedValueController.text) ?? 0.0,
      imageUrls: const [],
      status: ClaimStatus.underReview,
      disasterDate: _selectedDisasterDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final beforeCount = claimProvider.claims.length;
    debugPrint("ℹ️ [_handleRegisterClaim] beforeCount=$beforeCount");

    bool success = false;

    try {
      success = await claimProvider.addClaim(claim);
    } catch (e) {
      debugPrint('❌ register claim error: $e');
      success = false;
    }

    if (!mounted) return;

    setState(() {
      _isRegistering = false;
    });

    final afterCount = claimProvider.claims.length;
    debugPrint("ℹ️ [_handleRegisterClaim] afterCount=$afterCount");

    if (success) {
      Claim? newClaim;
      if (afterCount > beforeCount) {
        newClaim = claimProvider.claims.last;
      }

      setState(() {
        _createdClaimId = newClaim?.id;
      });

      debugPrint("✅ [_handleRegisterClaim] createdClaimId=$_createdClaimId");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _createdClaimId != null
                ? loc.t('claim_registered_next_upload')
                : loc.t('claim_registered_no_id'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimProvider.error ?? loc.t('claim_error_register_failed'),
          ),
        ),
      );
    }
  }

  // STEP 2: upload evidence using provider
  Future<void> _handleUploadEvidence() async {
    final loc = AppLocalizations.of(context);

    if (_createdClaimId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('claim_error_no_claimid'))),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('claim_error_no_images'))),
      );
      return;
    }

    final claimProvider = context.read<ClaimProvider>();

    setState(() {
      _isUploadingEvidence = true;
    });

    debugPrint(
      "🔥 [_handleUploadEvidence] claimId=$_createdClaimId, files=${_selectedImages.length}",
    );

    bool success = false;
    try {
      success = await claimProvider.uploadEvidence(
        _createdClaimId!,
        _selectedImages,
      );
    } catch (e) {
      debugPrint('❌ upload evidence error: $e');
      success = false;
    }

    if (!mounted) return;

    setState(() {
      _isUploadingEvidence = false;
    });

    if (success) {
      debugPrint(
          "✅ [_handleUploadEvidence] evidence upload success for claimId=$_createdClaimId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('claim_evidence_upload_success'))),
      );
      context.go('/claims');
    } else {
      debugPrint(
          "❌ [_handleUploadEvidence] evidence upload failed, error=${claimProvider.error}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimProvider.error ?? loc.t('claim_evidence_upload_failed'),
          ),
        ),
      );
    }
  }
}