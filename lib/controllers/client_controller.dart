import 'package:flutter/foundation.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/services/database_service.dart';

enum ClientState { idle, loading, success, error }

class ClientController extends ChangeNotifier {
  final _db = DatabaseService();

  List<Client> _clients      = [];
  List<Client> _filtered     = [];
  ClientState  _state        = ClientState.idle;
  String       _errorMessage = '';
  String       _searchQuery  = '';

  List<Client> get clients      => _searchQuery.isEmpty ? _clients : _filtered;
  ClientState  get state        => _state;
  String       get errorMessage => _errorMessage;
  bool         get isLoading    => _state == ClientState.loading;

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> loadClients() async {
    _setState(ClientState.loading);
    try {
      _clients = await _db.getClients();
      _setState(ClientState.success);
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
      _filtered = _clients
          .where((c) =>
              c.nom.toLowerCase().contains(query.toLowerCase()) ||
              (c.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (c.telephone?.contains(query) ?? false))
          .toList();
    }
    notifyListeners();
  }

  // ── Add ───────────────────────────────────────────────────────────
  Future<bool> addClient(Client client) async {
    _setState(ClientState.loading);
    try {
      await _db.insertClient(client);
      await loadClients();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────
  Future<bool> updateClient(Client client) async {
    _setState(ClientState.loading);
    try {
      await _db.updateClient(client);
      await loadClients();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<bool> deleteClient(String id) async {
    _setState(ClientState.loading);
    try {
      await _db.deleteClient(id);
      _clients.removeWhere((c) => c.id == id);
      _setState(ClientState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void _setState(ClientState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _state        = ClientState.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _state        = ClientState.idle;
    notifyListeners();
  }
}