/// Constants - Global application configuration
/// Matches Constants.kt from the Android project
class Constants {
  Constants._();

  // =====================
  // API CONFIGURATION
  // =====================

  static const String baseUrl =
      'https://vannecontrol.swedencentral.cloudapp.azure.com/api/';

  static const int connectTimeoutSeconds = 30;
  static const int readTimeoutSeconds = 30;
  static const int writeTimeoutSeconds = 30;

  // =====================
  // AUTHENTICATION
  // =====================

  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  /// Secure storage keys (match Android SharedPreferences keys)
  static const String prefsName = 'piston_control_prefs';
  static const String prefsAuthToken = 'auth_token';
  static const String prefsUserId = 'user_id';
  static const String prefsUserEmail = 'user_email';
  static const String prefsValveLimit = 'valve_limit';

  // =====================
  // DEVICE & PISTON
  // =====================

  static const int pistonsPerDevice = 8;

  static const String actionActivate = 'activate';
  static const String actionDeactivate = 'deactivate';

  static const String stateActive = 'active';
  static const String stateInactive = 'inactive';

  static const String statusOnline = 'online';
  static const String statusOffline = 'offline';

  // =====================
  // WEBSOCKET
  // =====================

  static const String websocketUrl =
      'wss://vannecontrol.swedencentral.cloudapp.azure.com/ws';

  static const String wsTypePistonUpdate = 'piston_update';
  static const String wsTypeDeviceStatus = 'device_status';

  // =====================
  // ERROR MESSAGES
  // =====================

  static const String errorNoInternet = 'Pas de connexion Internet';
  static const String errorServerUnreachable =
      'Impossible de contacter le serveur';
  static const String errorUnauthorized =
      'Session expirée, veuillez vous reconnecter';
  static const String errorUnknown = 'Une erreur inconnue s\'est produite';

  // =====================
  // LOGGING
  // =====================

  static const bool enableNetworkLogs = true;

  // =====================
  // AVATAR CONFIGURATION
  // =====================

  static const String _baseDomain =
      'https://vannecontrol.swedencentral.cloudapp.azure.com';

  /// Fix avatar URLs returned by backend.
  /// Handles localhost URLs → production domain, HTTP → HTTPS.
  static String? fixAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    var fixedUrl = url
        .replaceAll('http://localhost:8080', _baseDomain)
        .replaceAll('https://localhost:8080', _baseDomain)
        .replaceAll('http://127.0.0.1:8080', _baseDomain)
        .replaceAll('https://127.0.0.1:8080', _baseDomain);

    if (fixedUrl.startsWith(
        'http://vannecontrol.swedencentral.cloudapp.azure.com')) {
      fixedUrl = fixedUrl.replaceAll(
        'http://vannecontrol.swedencentral.cloudapp.azure.com',
        'https://vannecontrol.swedencentral.cloudapp.azure.com',
      );
    }

    if (fixedUrl.startsWith('http://') || fixedUrl.startsWith('https://')) {
      return fixedUrl;
    }
    return null;
  }
}
