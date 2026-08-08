import 'package:flutter/material.dart';

import 'app.dart';
import 'services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceLocator.initialize();

  runApp(const MovieTrackerApp());
}
