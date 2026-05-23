import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/billing/pro_upgrade_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('purchase activates pro', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = ProUpgradeNotifier();
    await notifier.purchase();
    expect(notifier.isActive, isTrue);
  });
}
