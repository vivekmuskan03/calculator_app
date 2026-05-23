/// Abstract interface for the banner advertisement manager.
///
/// Tracks completed calculations in memory and controls banner ad display
/// for free-tier users. Never shows interstitial, pop-up, or video ads
/// (Requirement 8.2).
abstract class AdManager {
  /// Called after each completed calculation.
  ///
  /// Increments the internal calculation counter. When the counter reaches
  /// a multiple of 5 and the user is on the free tier, sets [shouldShowBanner]
  /// to true (Requirement 8.1).
  void onCalculationCompleted();

  /// Whether a banner advertisement should currently be displayed.
  ///
  /// Returns false when [ProUpgrade.isActive] is true (Requirement 8.4).
  /// The calculation count resets on app restart (not persisted).
  bool get shouldShowBanner;
}
