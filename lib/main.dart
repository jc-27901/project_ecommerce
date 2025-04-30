// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_ecommerce/features/authentication/authentication_feature.dart';
import 'package:project_ecommerce/provider/address_provider.dart';
import 'package:project_ecommerce/provider/authentication_provider.dart';
import 'package:project_ecommerce/provider/cart_provider.dart';
import 'package:project_ecommerce/provider/product_provider.dart';
import 'package:project_ecommerce/provider/user_profile_provider.dart';
import 'package:project_ecommerce/services/firebase_services.dart';
import 'package:provider/provider.dart';

import 'features/authentication/authentication_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BaseFirebaseService>(
          create: (_) => FirebaseService(),
        ),
        ChangeNotifierProxyProvider<BaseFirebaseService, ProductProvider>(
          create: (context) =>
              ProductProvider(context.read<BaseFirebaseService>()),
          update: (context, service, previous) =>
              previous ?? ProductProvider(service),
        ),


        ChangeNotifierProxyProvider<BaseFirebaseService,
            UserProfileProvider>(
          create: (context) =>
              UserProfileProvider(context.read<BaseFirebaseService>()),
          update: (context, service, previous) =>
          previous ?? UserProfileProvider(service),
        ),

        ChangeNotifierProxyProvider<BaseFirebaseService,
            AuthenticationProvider>(
          create: (context) =>
              AuthenticationProvider(context.read<BaseFirebaseService>()),
          update: (context, service, previous) =>
              previous ?? AuthenticationProvider(service),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressProvider(
            context.read<BaseFirebaseService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => CartProvider(
            context.read<BaseFirebaseService>(),
          ),
        ),
        // ChangeNotifierProxyProvider<BaseFirebaseService, UserProfileProvider>(
        //   create: (_) => UserProfileProvider(
        //     context.read<BaseFirebaseService>(),
        //   ),
        //   update: (context, service, previous) =>
        //       previous ?? UserProfileProvider(service),
        // ),
      ],
      child: MaterialApp(
        title: 'Firebase E-commerce',
        home: AuthenticationRouter(
          authenticationScreen: const AuthenticationFeature(),
        ),
      ),
    );
  }
}
