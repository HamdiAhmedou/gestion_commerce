import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_commerce/views/screens/dashboard/dashboard_screen.dart';
import 'package:gestion_commerce/views/screens/produits/produits_screen.dart';
import 'package:gestion_commerce/views/screens/produits/produit_form_screen.dart';
import 'package:gestion_commerce/views/screens/clients/clients_screen.dart';
import 'package:gestion_commerce/views/screens/clients/client_form_screen.dart';
import 'package:gestion_commerce/views/screens/commandes/commandes_screen.dart';
import 'package:gestion_commerce/views/screens/commandes/commande_form_screen.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/models/commande.dart';
class AppRouter {
  static const dashboard = '/';
  static const produits = '/produits';
  static const produitAdd = '/produits/add';
  static const produitEdit = '/produits/edit';
  static const clients = '/clients';
  static const clientAdd = '/clients/add';
  static const clientEdit = '/clients/edit';
  static const commandes = '/commandes';
  static const commandeAdd = '/commandes/add';
  static const commandeDetail = '/commandes/detail';

  static final router = GoRouter(
    initialLocation: dashboard,
    debugLogDiagnostics: false,
    routes: [
      // ── Dashboard ──────────────────────────────────────────────
      GoRoute(
        path: dashboard,
        pageBuilder: (context, state) => _slide(state, const DashboardScreen()),
      ),

      // ── Produits ───────────────────────────────────────────────
      GoRoute(
        path: produits,
        pageBuilder: (context, state) => _slide(state, const ProduitsScreen()),
      ),
      GoRoute(
        path: produitAdd,
        pageBuilder: (context, state) =>
            _modal(state, const ProduitFormScreen()),
      ),
      GoRoute(
        path: produitEdit,
        pageBuilder: (context, state) {
          final produit = state.extra as Produit;
          return _modal(state, ProduitFormScreen(produit: produit));
        },
      ),

      // ── Clients ────────────────────────────────────────────────
      GoRoute(
        path: clients,
        pageBuilder: (context, state) => _slide(state, const ClientsScreen()),
      ),
      GoRoute(
        path: clientAdd,
        pageBuilder: (context, state) =>
            _modal(state, const ClientFormScreen()),
      ),
      GoRoute(
        path: clientEdit,
        pageBuilder: (context, state) {
          final client = state.extra as Client;
          return _modal(state, ClientFormScreen(client: client));
        },
      ),

      // ── Commandes ──────────────────────────────────────────────
      GoRoute(
        path: commandes,
        pageBuilder: (context, state) => _slide(state, const CommandesScreen()),
      ),
      GoRoute(
        path: commandeAdd,
        pageBuilder: (context, state) =>
            _modal(state, const CommandeFormScreen()),
      ),
            GoRoute(
        path: commandeDetail,
        pageBuilder: (context, state) {
          final commande = state.extra as Commande;
          return _modal(state, CommandeFormScreen(commande: commande));
        },
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(child: Text('Page non trouvée: ${state.uri}')),
      ),
    ),
  );

  // ── Page transitions ───────────────────────────────────────────
  static CustomTransitionPage _slide(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _modal(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
