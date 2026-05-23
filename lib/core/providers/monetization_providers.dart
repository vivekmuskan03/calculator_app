import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/billing/pro_upgrade_impl.dart';
import 'package:nexacalc/core/billing/pro_upgrade_notifier.dart';
import 'package:nexacalc/core/ads/ad_manager_impl.dart';
import 'package:nexacalc/core/ads/ad_manager_notifier.dart';

final proUpgradeProvider = ChangeNotifierProvider<ProUpgradeNotifier>((ref) => ProUpgradeNotifier());

final adManagerProvider = ChangeNotifierProvider<AdManagerNotifier>((ref) {
  final pro = ref.read(proUpgradeProvider);
  final notifier = AdManagerNotifier(pro: pro);
  // Initialize persisted dismissal state asynchronously.
  notifier.init();
  return notifier;
});
