
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../../providers/crop_provider.dart';
// import '../../models/crop_model.dart';
// import '../../services/ml_service.dart';
// import '../../utils/app_colors.dart';

// class CropDetailScreen extends StatefulWidget {
//   final String cropId;

//   const CropDetailScreen({super.key, required this.cropId});

//   @override
//   State<CropDetailScreen> createState() => _CropDetailScreenState();
// }

// class _CropDetailScreenState extends State<CropDetailScreen> {
//   bool _isUploadingImage = false;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CropProvider>(
//       builder: (context, cropProvider, _) {
//         final crop = cropProvider.getCropById(widget.cropId);
        
//         if (crop == null) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Crop Details')),
//             body: const Center(
//               child: Text('Crop not found'),
//             ),
//           );
//         }

//         return Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => context.go('/crops'),
//             ),
//             title: Text(crop.name),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.edit),
//                 onPressed: () {
//                   // TODO: Implement edit functionality
//                 },
//               ),
//             ],
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Crop Image
//                 _buildCropImage(crop),
//                 const SizedBox(height: 24),
                
//                 // Basic Information
//                 _buildBasicInfo(crop),
//                 const SizedBox(height: 24),
                
//                 // Crop Stage Progress
//                 _buildStageProgress(crop),
//                 const SizedBox(height: 24),
                
//                 // Location Information
//                 _buildLocationInfo(crop),
//                 const SizedBox(height: 24),
                
//                 // Weekly Images Section
//                 _buildWeeklyImagesSection(crop),
//                 const SizedBox(height: 24),
                
//                 // Action Buttons
//                 _buildActionButtons(crop),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCropImage(Crop crop) {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: AppColors.background,
//       ),
//       child: crop.imageUrl != null
//           ? ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 crop.imageUrl!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return _buildPlaceholderImage();
//                 },
//               ),
//             )
//           : _buildPlaceholderImage(),
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.agriculture,
//             size: 60,
//             color: AppColors.primary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'No image available',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBasicInfo(Crop crop) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Basic Information',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildInfoRow('Crop Type', crop.typeDisplayName),
//           _buildInfoRow('Area', '${crop.area} acres'),
//           _buildInfoRow('Sowing Date', _formatDate(crop.sowingDate)),
//           _buildInfoRow('Current Stage', crop.stageDisplayName),
//           _buildInfoRow('Days Since Sowing', _calculateDaysSinceSowing(crop.sowingDate).toString()),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStageProgress(Crop crop) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Crop Stage Progress',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...CropStage.values.asMap().entries.map((entry) {
//             final index = entry.key;
//             final stage = entry.value;
//             final isCompleted = index <= CropStage.values.indexOf(crop.currentStage);
//             final isCurrent = stage == crop.currentStage;
            
//             return _buildStageItem(stage, isCompleted, isCurrent);
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStageItem(CropStage stage, bool isCompleted, bool isCurrent) {
//     Color stageColor;
//     IconData stageIcon;
    
//     switch (stage) {
//       case CropStage.sowing:
//         stageColor = AppColors.sowing;
//         stageIcon = Icons.agriculture;
//         break;
//       case CropStage.vegetative:
//         stageColor = AppColors.vegetative;
//         stageIcon = Icons.local_florist;
//         break;
//       case CropStage.flowering:
//         stageColor = AppColors.flowering;
//         stageIcon = Icons.eco;
//         break;
//       case CropStage.fruiting:
//         stageColor = AppColors.fruiting;
//         stageIcon = Icons.apple;
//         break;
//       case CropStage.harvest:
//         stageColor = AppColors.harvest;
//         stageIcon = Icons.grass;
//         break;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: isCompleted || isCurrent 
//                   ? stageColor 
//                   : AppColors.textSecondary.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               stageIcon,
//               color: isCompleted || isCurrent ? Colors.white : AppColors.textSecondary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _getStageDisplayName(stage),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
//                     color: isCurrent ? stageColor : AppColors.textPrimary,
//                   ),
//                 ),
//                 if (isCurrent)
//                   Text(
//                     'Current Stage',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: stageColor,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           if (isCompleted)
//             Icon(
//               Icons.check_circle,
//               color: AppColors.success,
//               size: 20,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationInfo(Crop crop) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Location Information',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildInfoRow('Address', crop.address),
//           _buildInfoRow('Latitude', crop.latitude.toStringAsFixed(6)),
//           _buildInfoRow('Longitude', crop.longitude.toStringAsFixed(6)),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // TODO: Open map with crop location
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Opening map...')),
//                 );
//               },
//               icon: const Icon(Icons.map),
//               label: const Text('View on Map'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(Crop crop) {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: () => _updateCropStage(crop),
//             icon: const Icon(Icons.update),
//             label: const Text('Update Stage'),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _reportLoss(crop),
//             icon: const Icon(Icons.report_problem),
//             label: const Text('Report Loss'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getStageDisplayName(CropStage stage) {
//     switch (stage) {
//       case CropStage.sowing:
//         return 'Sowing';
//       case CropStage.vegetative:
//         return 'Vegetative';
//       case CropStage.flowering:
//         return 'Flowering';
//       case CropStage.fruiting:
//         return 'Fruiting';
//       case CropStage.harvest:
//         return 'Harvest';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   int _calculateDaysSinceSowing(DateTime sowingDate) {
//     return DateTime.now().difference(sowingDate).inDays;
//   }

//   void _updateCropStage(Crop crop) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Update ${crop.name} Stage'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: CropStage.values.map((stage) {
//             return ListTile(
//               title: Text(_getStageDisplayName(stage)),
//               leading: Radio<CropStage>(
//                 value: stage,
//                 groupValue: crop.currentStage,
//                 onChanged: (value) {
//                   if (value != null) {
//                     context.read<CropProvider>().updateCropStage(crop.id, value);
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('${crop.name} stage updated to ${_getStageDisplayName(value)}')),
//                     );
//                   }
//                 },
//               ),
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _reportLoss(Crop crop) {
//     context.go('/add-claim', extra: {'cropId': crop.id});
//   }

//   Widget _buildWeeklyImagesSection(Crop crop) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Text(
//               //   'Weekly Crop Images',
//               //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//               Expanded(
//                 child: Text(
//                   'Weekly Crop Images',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: _isUploadingImage ? null : () => _uploadWeeklyImage(crop),
//                 icon: _isUploadingImage
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.add_a_photo, size: 18),
//                 label: const Text('Upload Weekly Image'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (crop.weeklyImages.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.photo_library_outlined,
//                     size: 48,
//                     color: AppColors.textSecondary,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'No weekly images yet',
//                     style: TextStyle(color: AppColors.textSecondary),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Upload weekly images to monitor crop health',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 12,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             )
//           else
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: crop.weeklyImages.length,
//               itemBuilder: (context, index) {
//                 final cropImage = crop.weeklyImages[index];
//                 return _buildWeeklyImageCard(cropImage);
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeeklyImageCard(CropImage cropImage) {
//     final prediction = cropImage.healthPrediction;
    
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: prediction != null
//               ? (prediction.isHealthy ? AppColors.success : AppColors.error)
//               : AppColors.border,
//           width: prediction != null ? 2 : 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
//               child: Image.file(
//                 File(cropImage.imageUrl),
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: AppColors.background,
//                     child: const Icon(Icons.broken_image),
//                   );
//                 },
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       prediction?.isHealthy == true
//                           ? Icons.check_circle
//                           : prediction?.isHealthy == false
//                               ? Icons.warning
//                               : Icons.help_outline,
//                       size: 16,
//                       color: prediction?.isHealthy == true
//                           ? AppColors.success
//                           : prediction?.isHealthy == false
//                               ? AppColors.error
//                               : AppColors.textSecondary,
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         prediction?.isHealthy == true
//                             ? 'Healthy'
//                             : prediction?.isHealthy == false
//                                 ? 'Issue Detected'
//                                 : 'Analyzing...',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: prediction?.isHealthy == true
//                               ? AppColors.success
//                               : prediction?.isHealthy == false
//                                   ? AppColors.error
//                                   : AppColors.textSecondary,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (prediction != null && prediction.diseaseType != null) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     prediction.diseaseType!,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: AppColors.textSecondary,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//                 const SizedBox(height: 4),
//                 Text(
//                   _formatDateShort(cropImage.capturedDate),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _uploadWeeklyImage(Crop crop) async {
//     final status = await Permission.camera.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Camera permission is required to take a photo')),
//       );
//       return;
//     }

//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile == null) return;
    
//     setState(() {
//       _isUploadingImage = true;
//     });

//     try {
//       Uint8List? imageBytes;
//       File? imageFile;
//       if (kIsWeb) {
//         imageBytes = await pickedFile.readAsBytes();
//       } else {
//         imageFile = File(pickedFile.path);
//       }
      
//       // Get ML prediction
//       final prediction = await MLService.predictCropHealth(imageFile ?? File(''));
      
//       // Create crop image with prediction
//       final cropImage = CropImage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         cropId: crop.id,
//         imageUrl: imageFile?.path ?? '',
//         capturedDate: DateTime.now(),
//         notes: null,
//         healthPrediction: prediction,
//       );
      
//       // Add to crop
//       final cropProvider = context.read<CropProvider>();
//       await cropProvider.addWeeklyImage(crop.id, cropImage, imageBytes: imageBytes);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               prediction.isHealthy
//                   ? 'Image uploaded! Crop is healthy.'
//                   : 'Image uploaded! Issue detected: ${prediction.diseaseType ?? "Unknown"}',
//             ),
//             backgroundColor: prediction.isHealthy ? AppColors.success : AppColors.error,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading image: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploadingImage = false;
//         });
//       }
//     }
//   }

//   String _formatDateShort(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/crop_provider.dart';
import '../../models/crop_model.dart';
import '../../services/ml_service.dart';
import '../../utils/app_colors.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        final crop = cropProvider.getCropById(widget.cropId);

        if (crop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('फसल विवरण')),
            body: const Center(
              child: Text('फसल नहीं मिली'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/crops'),
            ),
            title: Text(crop.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit functionality
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Image
                _buildCropImage(crop),
                const SizedBox(height: 24),

                // Basic Information
                _buildBasicInfo(crop),
                const SizedBox(height: 24),

                // Crop Stage Progress
                _buildStageProgress(crop),
                const SizedBox(height: 24),

                // Location Information
                _buildLocationInfo(crop),
                const SizedBox(height: 24),

                // Weekly Images Section
                _buildWeeklyImagesSection(crop),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(crop),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropImage(Crop crop) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
      ),
      child: crop.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                crop.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 60,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'कोई तस्वीर उपलब्ध नहीं है',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(Crop crop) {
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
          Text(
            'मूल जानकारी',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('फसल का प्रकार', crop.typeDisplayName),
          _buildInfoRow('क्षेत्रफल', '${crop.area} acres'),
          _buildInfoRow('बुवाई की तिथि', _formatDate(crop.sowingDate)),
          _buildInfoRow('वर्तमान चरण', crop.stageDisplayName),
          _buildInfoRow(
            'बुवाई के बाद के दिन',
            _calculateDaysSinceSowing(crop.sowingDate).toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress(Crop crop) {
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
          Text(
            'फसल चरण प्रगति',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...CropStage.values.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isCompleted =
                index <= CropStage.values.indexOf(crop.currentStage);
            final isCurrent = stage == crop.currentStage;

            return _buildStageItem(stage, isCompleted, isCurrent);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStageItem(CropStage stage, bool isCompleted, bool isCurrent) {
    Color stageColor;
    IconData stageIcon;

    switch (stage) {
      case CropStage.sowing:
        stageColor = AppColors.sowing;
        stageIcon = Icons.agriculture;
        break;
      case CropStage.vegetative:
        stageColor = AppColors.vegetative;
        stageIcon = Icons.local_florist;
        break;
      case CropStage.flowering:
        stageColor = AppColors.flowering;
        stageIcon = Icons.eco;
        break;
      case CropStage.fruiting:
        stageColor = AppColors.fruiting;
        stageIcon = Icons.apple;
        break;
      case CropStage.harvest:
        stageColor = AppColors.harvest;
        stageIcon = Icons.grass;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? stageColor
                  : AppColors.textSecondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stageIcon,
              color:
                  isCompleted || isCurrent ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStageDisplayName(stage),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent ? stageColor : AppColors.textPrimary,
                      ),
                ),
                if (isCurrent)
                  Text(
                    'वर्तमान चरण',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: stageColor,
                        ),
                  ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Crop crop) {
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
          Text(
            'स्थान संबंधी जानकारी',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('पता', crop.address),
          _buildInfoRow('अक्षांश', crop.latitude.toStringAsFixed(6)),
          _buildInfoRow('देशांतर', crop.longitude.toStringAsFixed(6)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Open map with crop location
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('मानचित्र खोला जा रहा है...'),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('मानचित्र पर देखें'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Crop crop) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _updateCropStage(crop),
            icon: const Icon(Icons.update),
            label: const Text('चरण अपडेट करें'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _reportLoss(crop),
            icon: const Icon(Icons.report_problem),
            label: const Text('नुकसान की रिपोर्ट करें'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getStageDisplayName(CropStage stage) {
    switch (stage) {
      case CropStage.sowing:
        return 'बुवाई';
      case CropStage.vegetative:
        return 'वनस्पतिक चरण';
      case CropStage.flowering:
        return 'फूल आने का चरण';
      case CropStage.fruiting:
        return 'फल आने का चरण';
      case CropStage.harvest:
        return 'कटाई';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDaysSinceSowing(DateTime sowingDate) {
    return DateTime.now().difference(sowingDate).inDays;
  }

  void _updateCropStage(Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${crop.name} का चरण अपडेट करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CropStage.values.map((stage) {
            return ListTile(
              title: Text(_getStageDisplayName(stage)),
              leading: Radio<CropStage>(
                value: stage,
                groupValue: crop.currentStage,
                onChanged: (value) {
                  if (value != null) {
                    context.read<CropProvider>().updateCropStage(
                          crop.id,
                          value,
                        );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${crop.name} का चरण बदला गया: ${_getStageDisplayName(value)}',
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('रद्द करें'),
          ),
        ],
      ),
    );
  }

  void _reportLoss(Crop crop) {
    context.go('/add-claim', extra: {'cropId': crop.id});
  }

  Widget _buildWeeklyImagesSection(Crop crop) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'साप्ताहिक फसल तस्वीरें',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    _isUploadingImage ? null : () => _uploadWeeklyImage(crop),
                icon: _isUploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_a_photo, size: 18),
                label: const Text('साप्ताहिक तस्वीर अपलोड करें'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (crop.weeklyImages.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'अभी तक कोई साप्ताहिक तस्वीर नहीं है',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'फसल की सेहत पर नज़र रखने के लिए साप्ताहिक तस्वीरें अपलोड करें',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: crop.weeklyImages.length,
              itemBuilder: (context, index) {
                final cropImage = crop.weeklyImages[index];
                return _buildWeeklyImageCard(cropImage);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyImageCard(CropImage cropImage) {
    final prediction = cropImage.healthPrediction;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: prediction != null
              ? (prediction.isHealthy ? AppColors.success : AppColors.error)
              : AppColors.border,
          width: prediction != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(7)),
              child: Image.file(
                File(cropImage.imageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      prediction?.isHealthy == true
                          ? Icons.check_circle
                          : prediction?.isHealthy == false
                              ? Icons.warning
                              : Icons.help_outline,
                      size: 16,
                      color: prediction?.isHealthy == true
                          ? AppColors.success
                          : prediction?.isHealthy == false
                              ? AppColors.error
                              : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        prediction?.isHealthy == true
                            ? 'स्वस्थ'
                            : prediction?.isHealthy == false
                                ? 'समस्या पाई गई'
                                : 'विश्लेषण हो रहा है...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: prediction?.isHealthy == true
                              ? AppColors.success
                              : prediction?.isHealthy == false
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (prediction != null &&
                    prediction.diseaseType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    prediction.diseaseType!,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDateShort(cropImage.capturedDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadWeeklyImage(Crop crop) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('फोटो लेने के लिए कैमरा अनुमति आवश्यक है'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      Uint8List? imageBytes;
      File? imageFile;
      if (kIsWeb) {
        imageBytes = await pickedFile.readAsBytes();
      } else {
        imageFile = File(pickedFile.path);
      }

      // Get ML prediction
      final prediction =
          await MLService.predictCropHealth(imageFile ?? File(''));

      // Create crop image with prediction
      final cropImage = CropImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropId: crop.id,
        imageUrl: imageFile?.path ?? '',
        capturedDate: DateTime.now(),
        notes: null,
        healthPrediction: prediction,
      );

      // Add to crop
      final cropProvider = context.read<CropProvider>();
      await cropProvider.addWeeklyImage(
        crop.id,
        cropImage,
        imageBytes: imageBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              prediction.isHealthy
                  ? 'तस्वीर अपलोड हो गई! फसल स्वस्थ है।'
                  : 'तस्वीर अपलोड हो गई! समस्या पाई गई: ${prediction.diseaseType ?? "अज्ञात"}',
            ),
            backgroundColor:
                prediction.isHealthy ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('तस्वीर अपलोड करते समय त्रुटि: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
