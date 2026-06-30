import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/router.dart';
import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';

class FeRaccoonsApp extends StatefulWidget {
  const FeRaccoonsApp({super.key});

  @override
  State<FeRaccoonsApp> createState() => _FeRaccoonsAppState();
}

class _FeRaccoonsAppState extends State<FeRaccoonsApp> {
  late final AuthController _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthController(api: ApiClient(), storage: AppStorage());
    _router = buildRouter(_auth);
    _auth.bootstrap(); // launch gate: token check -> /me
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'FE for Raccoons',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
