import 'package:flutter/foundation.dart';
import 'package:nexacalc/core/interfaces/pro_upgrade.dart';
import 'package:nexacalc/core/billing/pro_upgrade_impl.dart';
import 'package:nexacalc/core/billing/receipt_validator.dart';

class ProUpgradeNotifier extends ChangeNotifier implements ProUpgrade {
  final ProUpgradeImpl _impl = ProUpgradeImpl();

  ProUpgradeNotifier();

  @override
  bool get isActive => _impl.isActive;

  @override
  Future<void> purchase() async {
    await _impl.purchase();
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    await _impl.restore();
    notifyListeners();
  }

  Future<bool> validateWithServer(ReceiptValidator validator) async {
    return await _impl.validateReceiptWithServer(validator);
  }
}
