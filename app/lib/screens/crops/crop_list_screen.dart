import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/crop_provider.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';
import 'crop_detail_screen.dart';

// 🔹 localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  CropStage? _selectedStage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadCrops();
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
        title: Text(loc.t('crop_list_title')), // "My Crops"
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/add-crop'),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CropProvider>(
          builder: (context, cropProvider, _) {
            final crops = _selectedStage != null
                ? cropProvider.getCropsByStage(_selectedStage!)
                : cropProvider.crops;

            return RefreshIndicator(
              onRefresh: () async {
                await cropProvider.loadCrops();
              },
              child: Column(
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 4),
                  // 🔹 Main content
                  Expanded(
                    child: cropProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : crops.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                itemCount: crops.length,
                                itemBuilder: (context, index) {
                                  final crop = crops[index];
                                  return _buildCropCard(crop);
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-crop'),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------- FILTER SECTION ----------------

  Widget _buildFilterSection() {
    final loc = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('crop_list_filter_stage_title'), // "Filter by Stage"
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(loc.t('crop_list_filter_all'), null), // "All"
                const SizedBox(width: 8),
                ...CropStage.values.map((stage) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getStageDisplayName(stage),
                      stage,
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

  Widget _buildFilterChip(String label, CropStage? stage) {
    final isSelected = _selectedStage == stage;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStage = selected ? stage : null;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      selectedColor: AppColors.primary.withOpacity(0.18),
      checkmarkColor: AppColors.primary,
    );
  }

  // ---------------- EMPTY STATE ----------------

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);

    // 🔹 scrollable empty state so pull-to-refresh bhi kaam kare
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture_outlined,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.t('crop_list_empty_title'), // "No crops found"
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedStage != null
                          ? loc
                              .t('crop_list_empty_subtitle_stage')
                              .replaceAll(
                                '{stage}',
                                _getStageDisplayName(_selectedStage!),
                              )
                          : loc.t('crop_list_empty_subtitle_all'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/add-crop'),
                      icon: const Icon(Icons.add),
                      label: Text(loc.t('crop_list_add_button')), // "Add Crop"
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- CROP CARD ----------------

  Widget _buildCropCard(Crop crop) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/crop-detail/${crop.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top row: icon + name + stage chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _getCropStageColor(crop.currentStage)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.agriculture,
                        color: _getCropStageColor(crop.currentStage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            crop.typeDisplayName,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCropStageColor(crop.currentStage)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        crop.stageDisplayName,
                        style: TextStyle(
                          color: _getCropStageColor(crop.currentStage),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 🔹 Area + Sown date
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${crop.area} ${loc.t('unit_acres')}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${loc.t('crop_list_card_sown_prefix')} ${_formatDate(crop.sowingDate)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 🔹 Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        crop.address,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 🔹 Actions: Update stage / Report loss
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateCropStage(crop),
                        icon: const Icon(Icons.update, size: 16),
                        label: Text(
                          loc.t('crop_list_card_update_stage'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _reportLoss(crop),
                        icon: const Icon(Icons.report_problem, size: 16),
                        label: Text(
                          loc.t('crop_list_card_report_loss'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Color _getCropStageColor(CropStage stage) {
    switch (stage) {
      case CropStage.sowing:
        return AppColors.sowing;
      case CropStage.vegetative:
        return AppColors.vegetative;
      case CropStage.flowering:
        return AppColors.flowering;
      case CropStage.fruiting:
        return AppColors.fruiting;
      case CropStage.harvest:
        return AppColors.harvest;
    }
  }

  String _getStageDisplayName(CropStage stage) {
    // reuse same keys as detail screen
    final loc = AppLocalizations.of(context);

    switch (stage) {
      case CropStage.sowing:
        return loc.t('crop_stage_sowing');
      case CropStage.vegetative:
        return loc.t('crop_stage_vegetative');
      case CropStage.flowering:
        return loc.t('crop_stage_flowering');
      case CropStage.fruiting:
        return loc.t('crop_stage_fruiting');
      case CropStage.harvest:
        return loc.t('crop_stage_harvest');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateCropStage(Crop crop) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          loc
              .t('crop_list_update_dialog_title') // "Update {cropName} Stage"
              .replaceAll('{cropName}', crop.name),
        ),
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
                    context
                        .read<CropProvider>()
                        .updateCropStage(crop.id, value);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc
                              .t('crop_list_update_stage_success')
                              .replaceAll('{cropName}', crop.name)
                              .replaceAll(
                                '{stage}',
                                _getStageDisplayName(value),
                              ),
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
            child: Text(loc.t('common_cancel')),
          ),
        ],
      ),
    );
  }

  void _reportLoss(Crop crop) {
    context.go('/add-claim', extra: {'cropId': crop.id});
  }
}
