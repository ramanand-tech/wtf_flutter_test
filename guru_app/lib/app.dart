import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'screens/guru_root.dart';

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Guru App — DK',
      theme: buildAppTheme(primary: AppColors.guruPrimary, appName: 'Guru'),
      home: const GuruRootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
