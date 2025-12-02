import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import './screens/home/home_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/auth/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'GymKey',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: "/splash",
        routes: {
          "/splash": (context) => const SplashScreen(),
          "/login": (context) => const LoginScreen(),
          "/home": (context) => const HomeScreen(),
          "/signup":(context)=>const SignupScreen(),
        },
      ),
    );
  }
}
