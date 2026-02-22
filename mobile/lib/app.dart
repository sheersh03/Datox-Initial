import 'package:flutter/material.dart';
import 'routing/router.dart';
import 'theme/datox_theme.dart';

class DatoxApp extends StatelessWidget {
  const DatoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Datox',
      debugShowCheckedModeBanner: false,
      theme: DatoxTheme.light,
      routerConfig: appRouter,
    );
  }
}
