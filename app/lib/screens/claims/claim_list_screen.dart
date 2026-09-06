// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';

// import '../../providers/claim_provider.dart';
// import '../../providers/crop_provider.dart';
// import '../../models/claim_model.dart';
// import '../../utils/app_colors.dart';

// class ClaimListScreen extends StatefulWidget {
//   const ClaimListScreen({super.key});

//   @override
//   State<ClaimListScreen> createState() => _ClaimListScreenState();
// }

// class _ClaimListScreenState extends State<ClaimListScreen> {
//   ClaimStatus? _selectedStatus;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ClaimProvider>().loadClaims();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/home'),
//         ),
//         title: const Text('My Claims'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => context.go('/add-claim'),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter Section
//           _buildFilterSection(),
          
//           // Claims List
//           Expanded(
//             child: Consumer<ClaimProvider>(
//               builder: (context, claimProvider, _) {
//                 if (claimProvider.isLoading) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 final claims = _selectedStatus != null
//                     ? claimProvider.getClaimsByStatus(_selectedStatus!)
//                     : claimProvider.claims;

//                 if (claims.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: claims.length,
//                   itemBuilder: (context, index) {
//                     final claim = claims[index];
//                     return _buildClaimCard(claim);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.go('/add-claim'),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildFilterSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Filter by Status',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip('All', null),
//                 const SizedBox(width: 8),
//                 ...ClaimStatus.values.map((status) {
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: _buildFilterChip(
//                       _getStatusDisplayName(status),
//                       status,
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, ClaimStatus? status) {
//     final isSelected = _selectedStatus == status;
    
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (selected) {
//         setState(() {
//           _selectedStatus = selected ? status : null;
//         });
//       },
//       selectedColor: AppColors.primary.withOpacity(0.2),
//       checkmarkColor: AppColors.primary,
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.report_problem_outlined,
//               size: 80,
//               color: AppColors.textSecondary,
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No claims found',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _selectedStatus != null
//                   ? 'No claims with ${_getStatusDisplayName(_selectedStatus!)} status'
//                   : 'Report crop loss to file a claim',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () => context.go('/add-claim'),
//               icon: const Icon(Icons.add),
//               label: const Text('Report Loss'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClaimCard(Claim claim) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: _getDisasterTypeColor(claim.disasterType).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getDisasterTypeIcon(claim.disasterType),
//                       color: _getDisasterTypeColor(claim.disasterType),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           claim.disasterTypeDisplayName,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           'Crop: ${_getCropName(claim.cropId)}',
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(claim.status).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       claim.statusDisplayName,
//                       style: TextStyle(
//                         color: _getStatusColor(claim.status),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 claim.description,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.trending_down, size: 16, color: AppColors.textSecondary),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${claim.estimatedLoss.toStringAsFixed(1)}% loss',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
//                   const SizedBox(width: 4),
//                   Text(
//                     '₹${claim.estimatedValue.toStringAsFixed(0)}',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Disaster: ${_formatDate(claim.disasterDate)}',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//               if (claim.approvedAmount != null) ...[
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.success.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: AppColors.success, size: 16),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Approved Amount: ₹${claim.approvedAmount!.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           color: AppColors.success,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getDisasterTypeColor(DisasterType type) {
//     switch (type) {
//       case DisasterType.flood:
//         return AppColors.info;
//       case DisasterType.drought:
//         return AppColors.warning;
//       case DisasterType.pestAttack:
//         return AppColors.error;
//       case DisasterType.disease:
//         return AppColors.error;
//       case DisasterType.hailstorm:
//         return AppColors.info;
//       case DisasterType.cyclone:
//         return AppColors.error;
//       case DisasterType.fire:
//         return AppColors.error;
//       case DisasterType.other:
//         return AppColors.textSecondary;
//     }
//   }

//   IconData _getDisasterTypeIcon(DisasterType type) {
//     switch (type) {
//       case DisasterType.flood:
//         return Icons.water;
//       case DisasterType.drought:
//         return Icons.wb_sunny;
//       case DisasterType.pestAttack:
//         return Icons.bug_report;
//       case DisasterType.disease:
//         return Icons.medical_services;
//       case DisasterType.hailstorm:
//         return Icons.ac_unit;
//       case DisasterType.cyclone:
//         return Icons.storm;
//       case DisasterType.fire:
//         return Icons.local_fire_department;
//       case DisasterType.other:
//         return Icons.warning;
//     }
//   }

//   Color _getStatusColor(ClaimStatus status) {
//     switch (status) {
//       case ClaimStatus.underReview:
//         return AppColors.underReview;
//       case ClaimStatus.verified:
//         return AppColors.verified;
//       case ClaimStatus.approved:
//         return AppColors.approved;
//       case ClaimStatus.paid:
//         return AppColors.paid;
//       case ClaimStatus.rejected:
//         return AppColors.error;
//     }
//   }

//   String _getStatusDisplayName(ClaimStatus status) {
//     switch (status) {
//       case ClaimStatus.underReview:
//         return 'Under Review';
//       case ClaimStatus.verified:
//         return 'Verified';
//       case ClaimStatus.approved:
//         return 'Approved';
//       case ClaimStatus.paid:
//         return 'Paid';
//       case ClaimStatus.rejected:
//         return 'Rejected';
//     }
//   }

//   String _getCropName(String cropId) {
//     final cropProvider = context.read<CropProvider>();
//     final crop = cropProvider.getCropById(cropId);
//     return crop?.name ?? 'Unknown Crop';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/claim_provider.dart';
import '../../providers/crop_provider.dart';
import '../../models/claim_model.dart';
import '../../utils/app_colors.dart';

// 🔹 NEW: localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class ClaimListScreen extends StatefulWidget {
  const ClaimListScreen({super.key});

  @override
  State<ClaimListScreen> createState() => _ClaimListScreenState();
}

class _ClaimListScreenState extends State<ClaimListScreen> {
  ClaimStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimProvider>().loadClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(loc.t('claims_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/add-claim'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(context),

          // Claims List
          Expanded(
            child: Consumer<ClaimProvider>(
              builder: (context, claimProvider, _) {
                if (claimProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final claims = _selectedStatus != null
                    ? claimProvider.getClaimsByStatus(_selectedStatus!)
                    : claimProvider.claims;

                if (claims.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: claims.length,
                  itemBuilder: (context, index) {
                    final claim = claims[index];
                    return _buildClaimCard(context, claim);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-claim'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('claims_filter_by_status'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, loc.t('claims_filter_all'), null),
                const SizedBox(width: 8),
                ...ClaimStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      context,
                      _getStatusDisplayName(context, status),
                      status,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    ClaimStatus? status,
  ) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              loc.t('claims_empty_title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus != null
                  ? '${loc.t('claims_empty_filtered_prefix')} '
                    '${_getStatusDisplayName(context, _selectedStatus!)} '
                    '${loc.t('claims_empty_filtered_suffix')}'
                  : loc.t('claims_empty_sub_all'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-claim'),
              icon: const Icon(Icons.add),
              label: Text(loc.t('claims_report_loss_button')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, Claim claim) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getDisasterTypeColor(claim.disasterType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDisasterTypeIcon(claim.disasterType),
                      color: _getDisasterTypeColor(claim.disasterType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disaster type name localised
                        Text(
                          _getDisasterTypeLocalizedName(
                              context, claim.disasterType),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${loc.t('claims_crop_prefix')} '
                          '${_getCropName(context, claim.cropId)}',
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(claim.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(context, claim.status),
                      style: TextStyle(
                        color: _getStatusColor(claim.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                claim.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.trending_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${claim.estimatedLoss.toStringAsFixed(1)}'
                    '${loc.t('claims_loss_label_suffix')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${claim.estimatedValue.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${loc.t('claims_disaster_prefix')} '
                    '${_formatDate(claim.disasterDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              if (claim.approvedAmount != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${loc.t('claims_approved_amount_prefix')} '
                        '₹${claim.approvedAmount!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDisasterTypeColor(DisasterType type) {
    switch (type) {
      case DisasterType.flood:
        return AppColors.info;
      case DisasterType.drought:
        return AppColors.warning;
      case DisasterType.pestAttack:
        return AppColors.error;
      case DisasterType.disease:
        return AppColors.error;
      case DisasterType.hailstorm:
        return AppColors.info;
      case DisasterType.cyclone:
        return AppColors.error;
      case DisasterType.fire:
        return AppColors.error;
      case DisasterType.other:
        return AppColors.textSecondary;
    }
  }

  IconData _getDisasterTypeIcon(DisasterType type) {
    switch (type) {
      case DisasterType.flood:
        return Icons.water;
      case DisasterType.drought:
        return Icons.wb_sunny;
      case DisasterType.pestAttack:
        return Icons.bug_report;
      case DisasterType.disease:
        return Icons.medical_services;
      case DisasterType.hailstorm:
        return Icons.ac_unit;
      case DisasterType.cyclone:
        return Icons.storm;
      case DisasterType.fire:
        return Icons.local_fire_department;
      case DisasterType.other:
        return Icons.warning;
    }
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.underReview:
        return AppColors.underReview;
      case ClaimStatus.verified:
        return AppColors.verified;
      case ClaimStatus.approved:
        return AppColors.approved;
      case ClaimStatus.paid:
        return AppColors.paid;
      case ClaimStatus.rejected:
        return AppColors.error;
    }
  }

  String _getStatusDisplayName(BuildContext context, ClaimStatus status) {
    final loc = AppLocalizations.of(context);

    switch (status) {
      case ClaimStatus.underReview:
        return loc.t('status_under_review');
      case ClaimStatus.verified:
        return loc.t('status_verified');
      case ClaimStatus.approved:
        return loc.t('status_approved');
      case ClaimStatus.paid:
        return loc.t('status_paid');
      case ClaimStatus.rejected:
        return loc.t('status_rejected');
    }
  }

  String _getDisasterTypeLocalizedName(
      BuildContext context, DisasterType type) {
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

  String _getCropName(BuildContext context, String cropId) {
    final loc = AppLocalizations.of(context);
    final cropProvider = context.read<CropProvider>();
    final crop = cropProvider.getCropById(cropId);
    return crop?.name ?? loc.t('unknown_crop');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}