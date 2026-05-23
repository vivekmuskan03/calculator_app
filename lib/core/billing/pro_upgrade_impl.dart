import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexacalc/core/interfaces/pro_upgrade.dart';
import 'package:nexacalc/core/billing/receipt_validator.dart';

class ProUpgradeImpl implements ProUpgrade {
  static const _activeKey = 'pro_upgrade_active';
  static const _receiptKey = 'pro_upgrade_receipt';

  bool _isActive = false;

  final String? serverReceiptKey;

  ProUpgradeImpl({this.serverReceiptKey}) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isActive = prefs.getBool(_activeKey) ?? false;
  }

  @override
  bool get isActive => _isActive;

  @override
  Future<void> purchase() async {
    // NOTE: In production, integrate with `in_app_purchase` and validate
    // receipts with a trusted server. For the MVP, persist a local receipt
    // placeholder to enable Pro flows during development.
    final prefs = await SharedPreferences.getInstance();
    final receipt = jsonEncode({'provider': 'dev', 'timestamp': DateTime.now().toIso8601String()});
    await prefs.setString(_receiptKey, receipt);
    await prefs.setBool(_activeKey, true);
    _isActive = true;
  }

  @override
  Future<void> restore() async {
    // Restore from saved receipt in SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final receipt = prefs.getString(_receiptKey);
    if (receipt != null) {
      // In production validate receipt properly.
      await prefs.setBool(_activeKey, true);
      _isActive = true;
      return;
    }
    throw Exception('No receipt to restore');
  }

  /// Validate stored receipt with a remote validator. Returns true if
  /// validation succeeded and activates Pro locally.
  Future<bool> validateReceiptWithServer(ReceiptValidator validator) async {
    final prefs = await SharedPreferences.getInstance();
    final receipt = prefs.getString(_receiptKey);
    if (receipt == null) return false;
    final ok = await validator.validate(receipt);
    if (ok) {
      await prefs.setBool(_activeKey, true);
      _isActive = true;
    }
    return ok;
  }
}
