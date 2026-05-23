import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'demo_app.dart';

/// Entry point for NexaCalc.
///
/// Wraps the entire widget tree in a [ProviderScope] so that all Riverpod
/// providers are accessible throughout the app (Requirement 9.1).
void main() {
  // Ensure Flutter bindings are initialised before accessing platform channels
  // (required by sqflite, shared_preferences, in_app_purchase, etc.).
  WidgetsFlutterBinding.ensureInitialized();

  final isDesktopOrWeb = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.fuchsia;

  runApp(
    isDesktopOrWeb
        ? const NexaCalcDemoApp()
        : const ProviderScope(
            child: NexaCalcApp(),
          ),
  );
}
