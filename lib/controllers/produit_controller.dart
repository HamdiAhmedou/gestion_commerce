import 'package:flutter/foundation.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/services/database_service.dart';
import 'package:gestion_commerce/services/api_service.dart';

enum ProduitState { idle, loading, success, error }

class ProduitController extends ChangeNotifier {
  final _db  = DatabaseService();
  final _api = ApiService();

  List<Produit> _produits     = [];
  List<Produit> _filtered     = [];
  ProduitState  _state        = ProduitState.idle;
  String        _errorMessage = '';
  String        _searchQuery  = '';

  List<Produit> get produits      => _searchQuery.isEmpty ? _produits : _filtered;
  ProduitState  get state         => _state;
  String        get errorMessage  => _errorMessage;
  bool          get isLoading     => _state == ProduitState.loading;

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> loadProduits() async {
    _setState(ProduitState.loading);
    try {
      _produits = await _db.getProduits();
      _setState(ProduitState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Search ────────────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filtered = [];
    } else {
      _filtered = _produits
          .where((p) =>
              p.nom.toLowerCase().contains(query.toLowerCase()) ||
              (p.categorie?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }

  // ── Add ───────────────────────────────────────────────────────────
  Future<bool> addProduit(Produit produit) async {
    _setState(ProduitState.loading);
    try {
      await _db.insertProduit(produit);
      await loadProduits();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────
  Future<bool> updateProduit(Produit produit) async {
    _setState(ProduitState.loading);
    try {
      await _db.updateProduit(produit);
      await loadProduits();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<bool> deleteProduit(String id) async {
    _setState(ProduitState.loading);
    try {
      await _db.deleteProduit(id);
      _produits.removeWhere((p) => p.id == id);
      _setState(ProduitState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Import from API ───────────────────────────────────────────────
  Future<bool> importFromApi() async {
    _setState(ProduitState.loading);
    try {
      final produits = await _api.fetchProduitsFromApi();
      await _db.insertProduits(produits);
      await loadProduits();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void _setState(ProduitState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _state        = ProduitState.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _state        = ProduitState.idle;
    notifyListeners();
  }
}