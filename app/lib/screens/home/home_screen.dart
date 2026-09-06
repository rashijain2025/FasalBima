
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:go_router/go_router.dart';

// // import '../../providers/auth_provider.dart';
// // import '../../providers/crop_provider.dart';
// // import '../../providers/claim_provider.dart';
// // import '../../providers/weather_provider.dart';
// // import '../../models/crop_model.dart';
// // import '../../utils/app_colors.dart';
// // import '../crops/crop_list_screen.dart';
// // import '../claims/claim_list_screen.dart';
// // import '../insights/insights_screen.dart';
// // import '../profile/profile_screen.dart';

// // // 🔹 NEW: localization
// // import '../../localization/app_localizations.dart';
// // import '../../localization/locale_provider.dart';

// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   int _selectedIndex = 0;

// //   late final List<Widget> _screens = [
// //     const HomeTab(),
// //     const CropListScreen(),
// //     const ClaimListScreen(),
// //     const InsightsScreen(),
// //     const ProfileScreen(),
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context.read<CropProvider>().loadCrops();
// //       context.read<ClaimProvider>().loadClaims();

// //       // WeatherProvider ke liye default location (Bhopal example)
// //       context.read<WeatherProvider>().loadWeatherData(
// //             lat: 23.2599,
// //             lon: 77.4126,
// //           );
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Scaffold(
// //       body: _screens[_selectedIndex],
// //       bottomNavigationBar: BottomNavigationBar(
// //         type: BottomNavigationBarType.fixed,
// //         currentIndex: _selectedIndex,
// //         onTap: (index) {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //         },
// //         selectedItemColor: AppColors.primary,
// //         unselectedItemColor: AppColors.textSecondary,
// //         items: [
// //           BottomNavigationBarItem(
// //             icon: const Icon(Icons.home),
// //             label: loc.t('nav_home'),
// //           ),
// //           BottomNavigationBarItem(
// //             icon: const Icon(Icons.agriculture),
// //             label: loc.t('nav_crops'),
// //           ),
// //           BottomNavigationBarItem(
// //             icon: const Icon(Icons.report_problem),
// //             label: loc.t('nav_claims'),
// //           ),
// //           BottomNavigationBarItem(
// //             icon: const Icon(Icons.insights),
// //             label: loc.t('nav_insights'),
// //           ),
// //           BottomNavigationBarItem(
// //             icon: const Icon(Icons.person),
// //             label: loc.t('nav_profile'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class HomeTab extends StatelessWidget {
// //   const HomeTab({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final loc = AppLocalizations.of(context);
// //     final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(loc.t('home_dashboard_title')),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.language),
// //             onPressed: () => localeProvider.toggleLocale(),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.notifications),
// //             onPressed: () {
// //               // Handle notifications
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Welcome Section
// //             _buildWelcomeSection(context),
// //             const SizedBox(height: 24),

// //             // Quick Stats
// //             _buildQuickStats(context),
// //             const SizedBox(height: 24),

// //             // Recent Crops
// //             _buildRecentCrops(context),
// //             const SizedBox(height: 24),

// //             // Weather Alert
// //             _buildWeatherAlert(context),
// //             const SizedBox(height: 24),

// //             // Quick Actions
// //             _buildQuickActions(context),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWelcomeSection(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Consumer<AuthProvider>(
// //       builder: (context, authProvider, _) {
// //         final user = authProvider.user;
// //         return Container(
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [AppColors.primary, AppColors.primaryLight],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 loc.t('home_welcome_back'),
// //                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                       color: Colors.white70,
// //                     ),
// //               ),
// //               Text(
// //                 user?.name.isNotEmpty == true
// //                     ? user!.name
// //                     : loc.t('home_farmer_fallback'),
// //                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 loc.t('home_welcome_subtitle'),
// //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                       color: Colors.white70,
// //                     ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildQuickStats(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Consumer<CropProvider>(
// //       builder: (context, cropProvider, _) {
// //         final crops = cropProvider.crops;
// //         final totalCrops = crops.length;
// //         final totalArea = crops.fold(0.0, (sum, crop) => sum + crop.area);

// //         return Row(
// //           children: [
// //             Expanded(
// //               child: _buildStatCard(
// //                 context,
// //                 loc.t('home_total_crops'),
// //                 totalCrops.toString(),
// //                 Icons.agriculture,
// //                 AppColors.primary,
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: _buildStatCard(
// //                 context,
// //                 loc.t('home_total_area'),
// //                 '${totalArea.toStringAsFixed(1)} ${loc.t('unit_acres')}',
// //                 Icons.straighten,
// //                 AppColors.secondary,
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildStatCard(
// //     BuildContext context,
// //     String title,
// //     String value,
// //     IconData icon,
// //     Color color,
// //   ) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(icon, color: color, size: 32),
// //           const SizedBox(height: 8),
// //           Text(
// //             value,
// //             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
// //                   fontWeight: FontWeight.bold,
// //                   color: AppColors.textPrimary,
// //                 ),
// //           ),
// //           Text(
// //             title,
// //             style: Theme.of(context).textTheme.bodySmall?.copyWith(
// //                   color: AppColors.textSecondary,
// //                 ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildRecentCrops(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text(
// //               loc.t('home_recent_crops'),
// //               style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //             ),
// //             TextButton(
// //               onPressed: () {
// //                 // ideally: context.go('/crops');
// //                 DefaultTabController.of(context)?.animateTo(1);
// //               },
// //               child: Text(loc.t('home_view_all')),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 12),
// //         Consumer<CropProvider>(
// //           builder: (context, cropProvider, _) {
// //             final recentCrops = cropProvider.crops.take(3).toList();

// //             if (recentCrops.isEmpty) {
// //               return Container(
// //                 padding: const EdgeInsets.all(32),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     Icon(
// //                       Icons.agriculture_outlined,
// //                       size: 48,
// //                       color: AppColors.textSecondary,
// //                     ),
// //                     const SizedBox(height: 16),
// //                     Text(
// //                       loc.t('home_no_crops_title'),
// //                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                             color: AppColors.textSecondary,
// //                           ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Text(
// //                       loc.t('home_no_crops_subtitle'),
// //                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                             color: AppColors.textSecondary,
// //                           ),
// //                     ),
// //                     const SizedBox(height: 16),
// //                     ElevatedButton.icon(
// //                       onPressed: () => context.go('/register-plot'),
// //                       icon: const Icon(Icons.add),
// //                       label: Text(loc.t('home_register_plot_button')),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }

// //             return Column(
// //               children: recentCrops.map((crop) {
// //                 return Container(
// //                   margin: const EdgeInsets.only(bottom: 8),
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.05),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Container(
// //                         width: 50,
// //                         height: 50,
// //                         decoration: BoxDecoration(
// //                           color: _getCropStageColor(crop.currentStage)
// //                               .withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: Icon(
// //                           Icons.agriculture,
// //                           color: _getCropStageColor(crop.currentStage),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               crop.name,
// //                               style: Theme.of(context)
// //                                   .textTheme
// //                                   .titleMedium
// //                                   ?.copyWith(
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                             ),
// //                             Text(
// //                               '${crop.typeDisplayName} • ${crop.area} ${loc.t('unit_acres')}',
// //                               style: Theme.of(context)
// //                                   .textTheme
// //                                   .bodySmall
// //                                   ?.copyWith(
// //                                     color: AppColors.textSecondary,
// //                                   ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 8, vertical: 4),
// //                         decoration: BoxDecoration(
// //                           color: _getCropStageColor(crop.currentStage)
// //                               .withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Text(
// //                           crop.stageDisplayName,
// //                           style: TextStyle(
// //                             color: _getCropStageColor(crop.currentStage),
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }).toList(),
// //             );
// //           },
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildWeatherAlert(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Consumer<WeatherProvider>(
// //       builder: (context, weatherProvider, _) {
// //         final alerts = weatherProvider.alerts;

// //         if (alerts.isEmpty) {
// //           return const SizedBox.shrink();
// //         }

// //         return Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: AppColors.warning.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: AppColors.warning.withOpacity(0.3)),
// //           ),
// //           child: Row(
// //             children: [
// //               Icon(Icons.warning, color: AppColors.warning),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       loc.t('home_weather_alert_title'),
// //                       style:
// //                           Theme.of(context).textTheme.titleMedium?.copyWith(
// //                                 fontWeight: FontWeight.w600,
// //                                 color: AppColors.warning,
// //                               ),
// //                     ),
// //                     Text(
// //                       alerts.first.title,
// //                       style:
// //                           Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                                 color: AppColors.warning,
// //                               ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildQuickActions(BuildContext context) {
// //     final loc = AppLocalizations.of(context);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           loc.t('home_quick_actions_title'),
// //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                 fontWeight: FontWeight.bold,
// //               ),
// //         ),
// //         const SizedBox(height: 12),
// //         Row(
// //           children: [
// //             Expanded(
// //               child: _buildActionCard(
// //                 context,
// //                 loc.t('home_action_register_plot'),
// //                 Icons.add_circle,
// //                 AppColors.primary,
// //                 () => context.go('/register-plot'),
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: _buildActionCard(
// //                 context,
// //                 loc.t('home_action_report_loss'),
// //                 Icons.report_problem,
// //                 AppColors.error,
// //                 () => context.go('/add-claim'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildActionCard(
// //     BuildContext context,
// //     String title,
// //     IconData icon,
// //     Color color,
// //     VoidCallback onTap,
// //   ) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(20),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 10,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           children: [
// //             Icon(icon, color: color, size: 32),
// //             const SizedBox(height: 8),
// //             Text(
// //               title,
// //               style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Color _getCropStageColor(CropStage stage) {
// //     switch (stage) {
// //       case CropStage.sowing:
// //         return AppColors.sowing;
// //       case CropStage.vegetative:
// //         return AppColors.vegetative;
// //       case CropStage.flowering:
// //         return AppColors.flowering;
// //       case CropStage.fruiting:
// //         return AppColors.fruiting;
// //       case CropStage.harvest:
// //         return AppColors.harvest;
// //     }
// //   }
// // }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/claim_provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';
import '../crops/crop_list_screen.dart';
import '../claims/claim_list_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

// 🔹 NEW: localization
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const HomeTab(),
    const CropListScreen(),
    const ClaimListScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadCrops();
      context.read<ClaimProvider>().loadClaims();

      // WeatherProvider ke liye default location (Bhopal example)
      context.read<WeatherProvider>().loadWeatherData(
            lat: 23.2599,
            lon: 77.4126,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: loc.t('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture),
            label: loc.t('nav_crops'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.report_problem),
            label: loc.t('nav_claims'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.insights),
            label: loc.t('nav_insights'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: loc.t('nav_profile'),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('home_dashboard_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push('/notifications'); // 🔔 yahan se notification page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context),
            const SizedBox(height: 24),

            // Recent Crops
            _buildRecentCrops(context),
            const SizedBox(height: 24),

            // Weather Alert
            _buildWeatherAlert(context),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('home_welcome_back'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              Text(
                user?.name.isNotEmpty == true
                    ? user!.name
                    : loc.t('home_farmer_fallback'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.t('home_welcome_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        final crops = cropProvider.crops;
        final totalCrops = crops.length;
        final totalArea = crops.fold(0.0, (sum, crop) => sum + crop.area);

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                loc.t('home_total_crops'),
                totalCrops.toString(),
                Icons.agriculture,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                loc.t('home_total_area'),
                '${totalArea.toStringAsFixed(1)} ${loc.t('unit_acres')}',
                Icons.straighten,
                AppColors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCrops(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.t('home_recent_crops'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // ideally: context.go('/crops');
                DefaultTabController.of(context)?.animateTo(1);
              },
              child: Text(loc.t('home_view_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<CropProvider>(
          builder: (context, cropProvider, _) {
            final recentCrops = cropProvider.crops.take(3).toList();

            if (recentCrops.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.agriculture_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.t('home_no_crops_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('home_no_crops_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/register-plot'),
                      icon: const Icon(Icons.add),
                      label: Text(loc.t('home_register_plot_button')),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: recentCrops.map((crop) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getCropStageColor(crop.currentStage)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${crop.typeDisplayName} • ${crop.area} ${loc.t('unit_acres')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeatherAlert(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        final alerts = weatherProvider.alerts;

        if (alerts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.t('home_weather_alert_title'),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                    ),
                    Text(
                      alerts.first.title,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.warning,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('home_quick_actions_title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                loc.t('home_action_register_plot'),
                Icons.add_circle,
                AppColors.primary,
                () => context.go('/register-plot'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                loc.t('home_action_report_loss'),
                Icons.report_problem,
                AppColors.error,
                () => context.go('/add-claim'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

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
}
