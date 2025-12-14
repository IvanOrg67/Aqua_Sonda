class AppConfig {
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sonda-f9zj.onrender.com',
  );
}
