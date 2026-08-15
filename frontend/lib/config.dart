class AppConfig {
  // Change this to your machine's LAN IP if running on a physical device.
  static const String apiBaseUrl = 'http://192.168.1.6:8000/api';

  // Philippine Standard Geographic Code (PSGC) API for address dropdowns
  // (Province -> Municipality -> Barangay).
  static const String psgcBaseUrl = 'https://psgc.gitlab.io/api';

  /// Builds a full URL for a stored file (e.g. "products/p1_1.png").
  /// Always resolves against [apiBaseUrl]'s host, so images work on
  /// physical devices too (LAN IP) instead of being hardcoded to 127.0.0.1.
  static String storageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$base/storage/$path';
  }
}