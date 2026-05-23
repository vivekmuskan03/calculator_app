import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  static const _kProId = 'nexacalc_pro';
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<void> init(void Function(PurchaseDetails) onPurchase) async {
    _sub = _iap.purchaseStream.listen((p) {
      for (final detail in p) {
        onPurchase(detail);
      }
    }, onError: (_) {});
  }

  Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails({_kProId});
    if (response.notFoundIDs.isNotEmpty) return [];
    return response.productDetails;
  }

  Future<void> buyPro() async {
    final available = await isAvailable();
    if (!available) throw StateError('In-app purchases unavailable');
    final products = await queryProducts();
    if (products.isEmpty) throw StateError('Pro product not found');
    final pd = products.first;
    final details = PurchaseParam(productDetails: pd);
    await _iap.buyNonConsumable(purchaseParam: details);
  }

  Future<void> restore() => _iap.restorePurchases();

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
