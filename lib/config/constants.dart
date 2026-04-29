class AppConstants {
  static const String apiBaseUrl = 'https://dummyjson.com';
  static const String apiProductsEndpoint = '/products?limit=30';

  static const String dbName = 'gestion_commerce.db';
  static const int dbVersion = 1;

  static const String tableProduits = 'produits';
  static const String tableClients = 'clients';
  static const String tableCommandes = 'commandes';
  static const String tableCommandeItems = 'commande_items';

  // Supported locales
  static const List<String> supportedLocales = ['fr', 'ar'];
  static const String defaultLocale = 'fr';
}