import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_commerce/config/constants.dart';
import 'package:gestion_commerce/models/produit.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  Future<List<Produit>> fetchProduitsFromApi() async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiProductsEndpoint}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List products = data['products'];
        return products.map((json) => Produit.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de contacter l\'API: $e');
    }
  }

  void dispose() => _client.close();
}