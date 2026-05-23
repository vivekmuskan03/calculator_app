import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Entry point for NexaCalc.
///
/// Wraps the entire widget tree in a [ProviderScope] so that all Riverpod
/// providers are accessible throughout the app (Requirement 9.1).
void main() {
  // Ensure Flutter bindings are initialised before accessing platform channels
  // (required by sqflite, shared_preferences, in_app_purchase, etc.).
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope is the root of the Riverpod state management tree.
    // All providers defined with flutter_riverpod are scoped here.
    const ProviderScope(
      child: NexaCalcApp(),
    ),
  );
}
