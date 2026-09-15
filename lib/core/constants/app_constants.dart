class AppConstants {
  static const String appName = 'Offline POS';
  static const String databaseName = 'offline_pos.db';
  static const int databaseVersion = 1;

  static const int retailMode = 0;
  static const int fnbMode = 1;

  static const int orderDraft = 0;
  static const int orderHeld = 1;
  static const int orderCompleted = 2;
  static const int orderCancelled = 3;
}
