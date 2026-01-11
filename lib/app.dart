// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'providers/auth_provider.dart';
// import 'providers/zone_provider.dart';
// import 'providers/location_provider.dart';
// import 'screens/splash_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart';
// import 'theme.dart';

// class GeoMuteApp extends StatefulWidget {
//   const GeoMuteApp({Key? key}) : super(key: key);

//   @override
//   _GeoMuteAppState createState() => _GeoMuteAppState();
// }

// class _GeoMuteAppState extends State<GeoMuteApp> {
//   bool _initialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeFirebase();
//   }

//   Future<void> _initializeFirebase() async {
//     await Firebase.initializeApp();
//     setState(() {
//       _initialized = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_initialized) {
//       return MaterialApp(
//         home: Scaffold(
//           backgroundColor: AppTheme.primaryColor,
//           body: Center(
//             child: CircularProgressIndicator(
//               color: Colors.white,
//             ),
//           ),
//         ),
//       );
//     }

//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ZoneProvider()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//       ],
//       child: MaterialApp(
//         title: 'GeoMute',
//         theme: AppTheme.lightTheme,
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/',
//         routes: {
//           '/': (context) => const AppWrapper(),
//           '/login': (context) => const LoginScreen(),
//           '/signup': (context) => const SignUpScreen(),
//           '/home': (context) => const HomeScreen(),
//         },
//       ),
//     );
//   }
// }

// class AppWrapper extends StatelessWidget {
//   const AppWrapper({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return FutureBuilder(
//       future: authProvider.initialize(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SplashScreen();
//         }

//         if (authProvider.isAuthenticated) {
//           return const HomeScreen();
//         }

//         return const AuthScreen();
//       },
//     );
//   }
// }

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({Key? key}) : super(key: key);

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [
//                   LoginScreen(),
//                   SignUpScreen(),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(20),
//               child: TabBar(
//                 controller: _tabController,
//                 labelColor: AppTheme.primaryColor,
//                 unselectedLabelColor: AppTheme.textHint,
//                 indicatorColor: AppTheme.primaryColor,
//                 tabs: const [
//                   Tab(text: 'Sign In'),
//                   Tab(text: 'Sign Up'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }