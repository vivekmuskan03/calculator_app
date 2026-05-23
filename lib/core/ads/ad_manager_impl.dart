import 'package:nexacalc/core/interfaces/ad_manager.dart';
import 'package:nexacalc/core/interfaces/pro_upgrade.dart';

class AdManagerImpl implements AdManager {
  final ProUpgrade pro;
  int _count = 0;
  bool _shouldShow = false;

  AdManagerImpl({required this.pro});

  @override
  void onCalculationCompleted() {
    _count++;
    if (!pro.isActive && _count % 5 == 0) {
      _shouldShow = true;
    } else {
      _shouldShow = false;
    }
  }

  @override
  bool get shouldShowBanner => !pro.isActive && _shouldShow;
}
