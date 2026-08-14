class AppConfig {
  // Change this to your machine's LAN IP if running on a physical device.
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';

  // Philippine Standard Geographic Code (PSGC) API for address dropdowns
  // (Province -> Municipality -> Barangay).
  static const String psgcBaseUrl = 'https://psgc.gitlab.io/api';
}