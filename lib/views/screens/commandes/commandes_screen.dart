import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/controllers/commande_controller.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/views/widgets/app_drawer.dart';
import 'package:gestion_commerce/views/widgets/empty_state.dart';
import 'package:gestion_commerce/views/widgets/loading_overlay.dart';
import 'package:gestion_commerce/views/widgets/confirm_dialog.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommandeController>().loadCommandes();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Commande> _filtered(List<Commande> all) {
    if (_searchCtrl.text.isEmpty) return all;
    return all
        .where(
          (c) => c.clientNom.toLowerCase().contains(
            _searchCtrl.text.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CommandeController>(
      builder: (context, ctrl, _) {
        final commandes = _filtered(ctrl.commandes);
        final isLoading = ctrl.isLoading;

        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0F0F1A)
                : const Color(0xFFF8F9FE),
            drawer: const AppDrawer(),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────────
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: isDark
                        ? const Color(0xFF0F0F1A)
                        : const Color(0xFFF8F9FE),
                    title: !_searchVisible
                        ? Text(
                            l10n.commandes,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: l10n.rechercher,
                              border: InputBorder.none,
                            ),
                          ),
                    actions: [
                      IconButton(
                        icon: Icon(_searchVisible ? Icons.close : Icons.search),
                        onPressed: () =>
                            setState(() => _searchVisible = !_searchVisible),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => context.push(AppRouter.commandeAdd),
                      ),
                    ],
                  ),

                  // ── List / Empty ─────────────────────────────────
                  if (commandes.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState.commandes(
                        onAdd: () => context.push(AppRouter.commandeAdd),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final c = commandes[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final confirmed =
                                          await ConfirmDialog.show(
                                            context,
                                            title: l10n.supprimer,
                                            message: l10n.confirmer,
                                            confirmText: l10n.supprimer,
                                            cancelText: l10n.annuler,
                                          );
                                      if (confirmed && mounted) {
                                        ctrl.deleteCommande(c.id ?? '');
                                      }
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_outline,
                                  ),
                                ],
                              ),
                              child: Card(
                                child: ListTile(
                                  title: Text(c.clientNom),
                                  subtitle: Text('${c.total} MRU'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: _colorForStatut(c.statut),
                                    ),
                                    child: Text(
                                      c.statut.toString().split('.').last,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  onTap: () => context.push(
                                    AppRouter.commandeDetail,
                                    extra: c,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }, childCount: commandes.length),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorForStatut(StatutCommande statut) {
    switch (statut) {
      case StatutCommande.enAttente:
        return Colors.orange;
      case StatutCommande.confirmee:
        return Colors.green;
      case StatutCommande.livree:
        return Colors.blue;
      case StatutCommande.annulee:
        return Colors.red;
    }
  }
}
