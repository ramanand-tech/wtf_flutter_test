import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.init(hiveBoxName: 'trainer_wtf_box');
  runApp(const ProviderScope(child: TrainerApp()));
}
