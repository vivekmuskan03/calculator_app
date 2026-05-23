import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/ads/ad_manager_notifier.dart';
import 'package:nexacalc/core/interfaces/pro_upgrade.dart';

class _FakePro implements ProUpgrade {
  bool active = false;
  @override
  bool get isActive => active;

  @override
  Future<void> purchase() async => active = true;

  @override
  Future<void> restore() async => active = true;
}

void main() {
  test('ad banner shows every 5 calculations when not pro', () {
    final pro = _FakePro();
    final ad = AdManagerNotifier(pro: pro);
    // Initially hidden
    expect(ad.shouldShowBanner, isFalse);
    for (var i = 1; i <= 4; i++) {
      ad.onCalculationCompleted();
      expect(ad.shouldShowBanner, isFalse, reason: 'after $i completions');
    }
    ad.onCalculationCompleted();
    expect(ad.shouldShowBanner, isTrue);
  });

  test('ad banner never shows for pro', () {
    final pro = _FakePro()..active = true;
    final ad = AdManagerNotifier(pro: pro);
    for (var i = 0; i < 10; i++) ad.onCalculationCompleted();
    expect(ad.shouldShowBanner, isFalse);
  });
}
