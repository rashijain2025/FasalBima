// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // localization
// // import 'package:flutter_localizations/flutter_localizations.dart';
// // import 'localization/app_localizations.dart';
// // import 'localization/locale_provider.dart';

// // // providers ko prefix de diye
// // import 'providers/auth_provider.dart' as auth;
// // import 'providers/crop_provider.dart' as crop;
// // import 'providers/claim_provider.dart' as claim;
// // import 'providers/weather_provider.dart' as weather;
// // import 'providers/plot_provider.dart' as plot;
// // import 'providers/notification_provider.dart' as notif; // 👈 NEW

// // import 'screens/auth/login_screen.dart';
// // import 'screens/auth/signup_screen.dart';
// // import 'screens/home/home_screen.dart';
// // import 'screens/crops/crop_list_screen.dart';
// // import 'screens/crops/add_crop_screen.dart';
// // import 'screens/crops/crop_detail_screen.dart';
// // import 'screens/plots/register_plot_screen.dart';
// // import 'screens/claims/claim_list_screen.dart';
// // import 'screens/claims/add_claim_screen.dart';
// // import 'screens/insights/insights_screen.dart';
// // import 'screens/profile/profile_screen.dart';
// // import 'screens/notifications/notification_screen.dart'; // 👈 NEW
// // import 'utils/app_colors.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   runApp(const FarmerApp());
// // }

// // class FarmerApp extends StatelessWidget {
// //   const FarmerApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiProvider(
// //       providers: [
// //         // locale provider
// //         ChangeNotifierProvider(
// //           create: (_) {
// //             final localeProvider = LocaleProvider();
// //             localeProvider.loadSavedLocale();
// //             return localeProvider;
// //           },
// //         ),

// //         // auth provider
// //         ChangeNotifierProvider(
// //           create: (_) {
// //             final authProvider = auth.AuthProvider();
// //             authProvider.loadUserFromStorage();
// //             return authProvider;
// //           },
// //         ),

// //         ChangeNotifierProvider(create: (_) => crop.CropProvider()),
// //         ChangeNotifierProvider(create: (_) => claim.ClaimProvider()),
// //         ChangeNotifierProvider(create: (_) => weather.WeatherProvider()),
// //         ChangeNotifierProvider(create: (_) => plot.PlotProvider()),
// //         ChangeNotifierProvider(create: (_) => notif.NotificationProvider()), // 👈 NEW
// //       ],
// //       child: Builder(
// //         builder: (context) {
// //           final authProvider = Provider.of<auth.AuthProvider>(context);
// //           final localeProvider = Provider.of<LocaleProvider>(context);

// //           return MaterialApp.router(
// //             title: 'Farmer App',
// //             debugShowCheckedModeBanner: false,

// //             // 🌐 localization
// //             locale: localeProvider.locale,
// //             supportedLocales: const [
// //               Locale('en'),
// //               Locale('hi'),
// //             ],
// //             localizationsDelegates: const [
// //               AppLocalizationsDelegate(),
// //               GlobalMaterialLocalizations.delegate,
// //               GlobalWidgetsLocalizations.delegate,
// //               GlobalCupertinoLocalizations.delegate,
// //             ],

// //             theme: ThemeData(
// //               primarySwatch: Colors.green,
// //               primaryColor: AppColors.primary,
// //               scaffoldBackgroundColor: AppColors.background,
// //               textTheme: GoogleFonts.poppinsTextTheme(),
// //               appBarTheme: AppBarTheme(
// //                 backgroundColor: AppColors.primary,
// //                 foregroundColor: Colors.white,
// //                 elevation: 0,
// //                 titleTextStyle: GoogleFonts.poppins(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               elevatedButtonTheme: ElevatedButtonThemeData(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: AppColors.primary,
// //                   foregroundColor: Colors.white,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                 ),
// //               ),
// //               inputDecorationTheme: InputDecorationTheme(
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   borderSide: BorderSide(color: AppColors.border),
// //                 ),
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   borderSide: BorderSide(color: AppColors.border),
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   borderSide:
// //                       BorderSide(color: AppColors.primary, width: 2),
// //                 ),
// //                 filled: true,
// //                 fillColor: Colors.white,
// //                 contentPadding: const EdgeInsets.symmetric(
// //                   horizontal: 16,
// //                   vertical: 16,
// //                 ),
// //               ),
// //             ),

// //             routerConfig: _createRouter(authProvider),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // GoRouter _createRouter(auth.AuthProvider authProvider) {
// //   return GoRouter(
// //     refreshListenable: authProvider,
// //     initialLocation: '/login',
// //     redirect: (context, state) {
// //       final isLoggedIn = authProvider.isAuthenticated;
// //       final isGoingToLogin =
// //           state.matchedLocation == '/login' ||
// //           state.matchedLocation == '/signup';

// //       if (!isLoggedIn && !isGoingToLogin) {
// //         return '/login';
// //       }

// //       if (isLoggedIn && isGoingToLogin) {
// //         return '/home';
// //       }

// //       return null;
// //     },
// //     routes: [
// //       GoRoute(
// //         path: '/login',
// //         builder: (context, state) => const LoginScreen(),
// //       ),
// //       GoRoute(
// //         path: '/signup',
// //         builder: (context, state) => const SignupScreen(),
// //       ),
// //       GoRoute(
// //         path: '/home',
// //         builder: (context, state) => const HomeScreen(),
// //       ),
// //       GoRoute(
// //         path: '/crops',
// //         builder: (context, state) => const CropListScreen(),
// //       ),
// //       GoRoute(
// //         path: '/register-plot',
// //         builder: (context, state) => const RegisterPlotScreen(),
// //       ),
// //       GoRoute(
// //         path: '/add-crop',
// //         builder: (context, state) => const AddCropScreen(),
// //       ),
// //       GoRoute(
// //         path: '/crop-detail/:id',
// //         builder: (context, state) {
// //           final cropId = state.pathParameters['id']!;
// //           return CropDetailScreen(cropId: cropId);
// //         },
// //       ),
// //       GoRoute(
// //         path: '/claims',
// //         builder: (context, state) => const ClaimListScreen(),
// //       ),
// //       GoRoute(
// //         path: '/add-claim',
// //         builder: (context, state) => const AddClaimScreen(),
// //       ),
// //       GoRoute(
// //         path: '/insights',
// //         builder: (context, state) => const InsightsScreen(),
// //       ),
// //       GoRoute(
// //         path: '/profile',
// //         builder: (context, state) => const ProfileScreen(),
// //       ),
// //       GoRoute(
// //         path: '/notifications', // 👈 NEW ROUTE
// //         builder: (context, state) => const NotificationScreen(),
// //       ),
// //     ],
// //   );
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';

// // localization
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'localization/app_localizations.dart';
// import 'localization/locale_provider.dart';

// // providers ko prefix de diye
// import 'providers/auth_provider.dart' as auth;
// import 'providers/crop_provider.dart' as crop;
// import 'providers/claim_provider.dart' as claim;
// import 'providers/weather_provider.dart' as weather;
// import 'providers/plot_provider.dart' as plot;
// // import 'providers/notification_provider.dart' as notif; // 👈 NEW

// import 'screens/auth/login_screen.dart';
// import 'screens/auth/signup_screen.dart';
// import 'screens/home/home_screen.dart';
// import 'screens/crops/crop_list_screen.dart';
// import 'screens/crops/add_crop_screen.dart';
// import 'screens/crops/crop_detail_screen.dart';
// import 'screens/plots/register_plot_screen.dart';
// import 'screens/claims/claim_list_screen.dart';
// import 'screens/claims/add_claim_screen.dart';
// import 'screens/insights/insights_screen.dart';
// import 'screens/profile/profile_screen.dart';
// // import 'screens/notifications/notification_screen.dart'; // 👈 NEW
// import 'utils/app_colors.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const FarmerApp());
// }

// class FarmerApp extends StatelessWidget {
//   const FarmerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // locale provider
//         ChangeNotifierProvider(
//           create: (_) {
//             final localeProvider = LocaleProvider();
//             localeProvider.loadSavedLocale();
//             return localeProvider;
//           },
//         ),

//         // auth provider
//         ChangeNotifierProvider(
//           create: (_) {
//             final authProvider = auth.AuthProvider();
//             authProvider.loadUserFromStorage();
//             return authProvider;
//           },
//         ),

//         ChangeNotifierProvider(create: (_) => crop.CropProvider()),
//         ChangeNotifierProvider(create: (_) => claim.ClaimProvider()),
//         ChangeNotifierProvider(create: (_) => weather.WeatherProvider()),
//         ChangeNotifierProvider(create: (_) => plot.PlotProvider()),
//         // ChangeNotifierProvider(create: (_) => notif.NotificationProvider()), // 👈 NEW
//       ],
//       child: Builder(
//         builder: (context) {
//           final authProvider = Provider.of<auth.AuthProvider>(context);
//           final localeProvider = Provider.of<LocaleProvider>(context);

//           return MaterialApp.router(
//             title: 'Farmer App',
//             debugShowCheckedModeBanner: false,

//             // 🌐 localization
//             locale: localeProvider.locale,
//             supportedLocales: const [
//               Locale('en'),
//               Locale('hi'),
//             ],
//             localizationsDelegates: const [
//               AppLocalizationsDelegate(),
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],

//             theme: ThemeData(
//               primarySwatch: Colors.green,
//               primaryColor: AppColors.primary,
//               scaffoldBackgroundColor: AppColors.background,
//               textTheme: GoogleFonts.poppinsTextTheme(),
//               appBarTheme: AppBarTheme(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 titleTextStyle: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//               ),
//               inputDecorationTheme: InputDecorationTheme(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.border),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.border),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       BorderSide(color: AppColors.primary, width: 2),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//               ),
//             ),

//             routerConfig: _createRouter(authProvider),
//           );
//         },
//       ),
//     );
//   }
// }

// GoRouter _createRouter(auth.AuthProvider authProvider) {
//   return GoRouter(
//     refreshListenable: authProvider,
//     initialLocation: '/login',
//     redirect: (context, state) {
//       final isLoggedIn = authProvider.isAuthenticated;
//       final isGoingToLogin =
//           state.matchedLocation == '/login' ||
//           state.matchedLocation == '/signup';

//       if (!isLoggedIn && !isGoingToLogin) {
//         return '/login';
//       }

//       if (isLoggedIn && isGoingToLogin) {
//         return '/home';
//       }

//       return null;
//     },
//     routes: [
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: '/signup',
//         builder: (context, state) => const SignupScreen(),
//       ),
//       GoRoute(
//         path: '/home',
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: '/crops',
//         builder: (context, state) => const CropListScreen(),
//       ),
//       GoRoute(
//         path: '/register-plot',
//         builder: (context, state) => const RegisterPlotScreen(),
//       ),
//       GoRoute(
//         path: '/add-crop',
//         builder: (context, state) => const AddCropScreen(),
//       ),
//       GoRoute(
//         path: '/crop-detail/:id',
//         builder: (context, state) {
//           final cropId = state.pathParameters['id']!;
//           return CropDetailScreen(cropId: cropId);
//         },
//       ),
//       GoRoute(
//         path: '/claims',
//         builder: (context, state) => const ClaimListScreen(),
//       ),
//       GoRoute(
//         path: '/add-claim',
//         builder: (context, state) => const AddClaimScreen(),
//       ),
//       GoRoute(
//         path: '/insights',
//         builder: (context, state) => const InsightsScreen(),
//       ),
//       GoRoute(
//         path: '/profile',
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       // GoRoute(
//       //   path: '/notifications', // 👈 NEW ROUTE
//       //   builder: (context, state) => const NotificationScreen(),
//       // ),
//     ],
//   );
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';

// providers ko prefix de diye
import 'providers/auth_provider.dart' as auth;
import 'providers/crop_provider.dart' as crop;
import 'providers/claim_provider.dart' as claim;
import 'providers/weather_provider.dart' as weather;
import 'providers/plot_provider.dart' as plot;
import 'providers/notification_provider.dart' as notif; // 👈 NEW

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/crops/crop_list_screen.dart';
import 'screens/crops/add_crop_screen.dart';
import 'screens/crops/crop_detail_screen.dart';
import 'screens/plots/register_plot_screen.dart';
import 'screens/claims/claim_list_screen.dart';
import 'screens/claims/add_claim_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notification_screen.dart'; // 👈 NEW
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmerApp());
}

class FarmerApp extends StatelessWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // locale provider
        ChangeNotifierProvider(
          create: (_) {
            final localeProvider = LocaleProvider();
            localeProvider.loadSavedLocale();
            return localeProvider;
          },
        ),

        // auth provider
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = auth.AuthProvider();
            authProvider.loadUserFromStorage();
            return authProvider;
          },
        ),

        ChangeNotifierProvider(create: (_) => crop.CropProvider()),
        ChangeNotifierProvider(create: (_) => claim.ClaimProvider()),
        ChangeNotifierProvider(create: (_) => weather.WeatherProvider()),
        ChangeNotifierProvider(create: (_) => plot.PlotProvider()),
        ChangeNotifierProvider(create: (_) => notif.NotificationProvider()), // 👈 NEW
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<auth.AuthProvider>(context);
          final localeProvider = Provider.of<LocaleProvider>(context);

          return MaterialApp.router(
            title: 'Farmer App',
            debugShowCheckedModeBanner: false,

            // 🌐 localization
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              textTheme: GoogleFonts.poppinsTextTheme(),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }
}

GoRouter _createRouter(auth.AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToLogin =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/crops',
        builder: (context, state) => const CropListScreen(),
      ),
      GoRoute(
        path: '/register-plot',
        builder: (context, state) => const RegisterPlotScreen(),
      ),
      GoRoute(
        path: '/add-crop',
        builder: (context, state) => const AddCropScreen(),
      ),
      GoRoute(
        path: '/crop-detail/:id',
        builder: (context, state) {
          final cropId = state.pathParameters['id']!;
          return CropDetailScreen(cropId: cropId);
        },
      ),
      GoRoute(
        path: '/claims',
        builder: (context, state) => const ClaimListScreen(),
      ),
      GoRoute(
        path: '/add-claim',
        builder: (context, state) => const AddClaimScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications', // 👈 NEW ROUTE
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
}
