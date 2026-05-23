import 'package:flutter/foundation.dart';
import 'ad_manager_impl.dart';
import 'package:nexacalc/core/interfaces/pro_upgrade.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDismissKey = 'ad_banner_dismissed_v1';

class AdManagerNotifier extends ChangeNotifier {
  final AdManagerImpl _impl;

  bool _dismissed = false;

  AdManagerNotifier({required ProUpgrade pro}) : _impl = AdManagerImpl(pro: pro);

  /// Load persisted dismissal state. Call this after construction.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _dismissed = prefs.getBool(_kDismissKey) ?? false;
    notifyListeners();
  }

  @override
  void onCalculationCompleted() {
    _impl.onCalculationCompleted();
    notifyListeners();
  }

  @override
  bool get shouldShowBanner => !_dismissed && _impl.shouldShowBanner;

  Future<void> dismissBanner() async {
    _dismissed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDismissKey, true);
    notifyListeners();
  }

  void clearDismissal() {
    _dismissed = false;
    SharedPreferences.getInstance().then((p) => p.setBool(_kDismissKey, false));
    notifyListeners();
  }
}
