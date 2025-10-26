class AppConfig {
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://sonda-f9zj.onrender.com',
  );
}
