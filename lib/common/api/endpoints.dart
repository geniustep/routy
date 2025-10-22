/// API Endpoints for Routy application (Odoo-based)
class ApiEndpoints {
  ApiEndpoints._();

  // Session endpoints
  static const String getSessionInfo = "web/session/get_session_info";
  static const String destroy = "web/session/destroy";
  static const String authenticate = "web/session/authenticate";

  // General Odoo endpoints
  static const String callKw = "web/dataset/call_kw";
  static const String searchRead = "web/dataset/call_kw";
  static const String getVersionInfo = "web/webclient/version_info";
  static const String getDatabases = "web/database/list";
  static const String getDb9 = "jsonrpc";
  static const String getDb10 = "web/database/list";
  static const String getDb = "web/database/get_list";
  static const String report = "xmlrpc/2/report";

  // Utility methods
  static String getCallKWEndPoint(String model, String method) {
    return callKw; // Use the same endpoint for all call_kw requests
  }
}
