class AppConfig {
  static const String appName = 'Football Marketplace';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://footbalmarketplace.albech.me/api';
  static const String apiBaseUrl = 'https://footbalmarketplace.albech.me/api';
  static const String socketUrl = 'https://footbalmarketplace.albech.me';
  // static const String baseUrl = 'http://192.168.72.1:3000/api';
  // static const String apiBaseUrl = 'http://192.168.72.1:3000/api';
  // static const String socketUrl = 'http://192.168.72.1:3000';
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // Chat
  static const int maxMessageLength = 2000;
  static const int messagePageSize = 50;

  // Constants
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String defaultCurrency = 'USD';

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String authError = 'Authentication failed. Please login again.';
}
