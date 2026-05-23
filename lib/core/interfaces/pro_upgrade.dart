/// Abstract interface for the one-time Pro upgrade in-app purchase.
///
/// Wraps the in_app_purchase Flutter plugin. Persists Pro status in
/// SharedPreferences so it is available on app launch without a network call
/// (Requirement 8.7, 8.8).
abstract class ProUpgrade {
  /// Whether the Pro upgrade is currently active for this user.
  ///
  /// Read from SharedPreferences on app launch (key: `pro_upgrade_active`).
  /// Only set to true after successful receipt validation (Requirement 8.7).
  bool get isActive;

  /// Initiates the in-app purchase flow for the Pro upgrade.
  ///
  /// On success, persists `pro_upgrade_active = true` and the receipt JSON
  /// in SharedPreferences (Requirement 8.7).
  ///
  /// Throws on purchase failure or user cancellation.
  Future<void> purchase();

  /// Restores a previously completed Pro upgrade purchase.
  ///
  /// Validates the restored receipt and updates [isActive] accordingly
  /// (Requirement 8.5).
  Future<void> restore();
}
