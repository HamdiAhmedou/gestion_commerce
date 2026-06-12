import 'package:flutter/foundation.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/services/database_service.dart';

enum CommandeState { idle, loading, success, error }

class CommandeController extends ChangeNotifier {
  final _db = DatabaseService();

  List<Commande> _commandes    = [];
  CommandeState  _state        = CommandeState.idle;
  String         _errorMessage = '';

  List<Commande> get commandes     => _commandes;
  CommandeState  get state         => _state;
  String         get errorMessage  => _errorMessage;
  bool           get isLoading     => _state == CommandeState.loading;

  // ── Stats for dashboard ───────────────────────────────────────────
  double get chiffreAffaires =>
      _commandes.fold(0, (sum, c) => sum + c.total);

  int get commandesEnAttente =>
      _commandes.where((c) => c.statut == StatutCommande.enAttente).length;

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> loadCommandes() async {
    _setState(CommandeState.loading);
    try {
      _commandes = await _db.getCommandes();
      _setState(CommandeState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Add ───────────────────────────────────────────────────────────
  Future<bool> addCommande(Commande commande) async {
    _setState(CommandeState.loading);
    try {
      await _db.insertCommande(commande);
      await loadCommandes();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  // ── Update statut ─────────────────────────────────────────────────
  Future<bool> updateStatut(String id, StatutCommande statut) async {
    _setState(CommandeState.loading);
    try {
      final index = _commandes.indexWhere((c) => c.id == id);
      final ancien = index != -1 ? _commandes[index].statut : null;

      if (ancien != null && ancien != statut) {
        if (statut == StatutCommande.annulee &&
            ancien != StatutCommande.annulee) {
          // Order cancelled → give the stock back
          await _db.restoreStock(_commandes[index].items);
        } else if (ancien == StatutCommande.annulee &&
            statut != StatutCommande.annulee) {
          // Order reactivated from cancelled → take stock again
          await _db.decrementStock(_commandes[index].items);
        }
      }

      await _db.updateCommandeStatut(id, statut.value);
      if (index != -1) {
        _commandes[index] = _commandes[index].copyWith(statut: statut);
      }
      _setState(CommandeState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<bool> deleteCommande(String id) async {
    _setState(CommandeState.loading);
    try {
      await _db.deleteCommande(id);
      _commandes.removeWhere((c) => c.id == id);
      _setState(CommandeState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void _setState(CommandeState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _state        = CommandeState.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _state        = CommandeState.idle;
    notifyListeners();
  }
}