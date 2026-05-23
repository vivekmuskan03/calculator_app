import 'package:flutter/foundation.dart';
import 'package:nexacalc/core/billing/pro_upgrade_impl.dart';
import 'package:nexacalc/core/billing/receipt_validator.dart';

class ProUpgradeNotifier extends ChangeNotifier {
  final ProUpgradeImpl _impl = ProUpgradeImpl();

  ProUpgradeNotifier() {
    // ensure prefs load
    _ensureLoaded();
  }

  bool get isActive => _impl.isActive;

  Future<void> _ensureLoaded() async {
    // ProUpgradeImpl loads from prefs on construction asynchronously.
    // Wait a tick and then notify so UI picks up any loaded state.
    await Future.delayed(Duration.zero);
    notifyListeners();
  }

  Future<void> purchase() async {
    await _impl.purchase();
    notifyListeners();
  }

  Future<void> restore() async {
    await _impl.restore();
    notifyListeners();
  }

  Future<bool> validateWithServer(ReceiptValidator validator) async {
    return await _impl.validateReceiptWithServer(validator);
  }
}
