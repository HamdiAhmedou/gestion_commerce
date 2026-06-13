import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
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
  StatutCommande? _statutFilter;

  static const _avatarColors = [
    AppTheme.primary,
    Color(0xFF0BA5A5),
    Color(0xFFE07B4F),
    Color(0xFF4CAF50),
    Color(0xFF7C5CBF),
    Color(0xFFEF5350),
  ];

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

  Color _colorFor(String name) {
    final code = name.isNotEmpty ? name.codeUnitAt(0) : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  List<Commande> _filter(List<Commande> commandes) {
    var list = commandes;
    if (_statutFilter != null) {
      list = list.where((c) => c.statut == _statutFilter).toList();
    }
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((c) => c.clientNom.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  String _statutLabel(StatutCommande s) {
    switch (s) {
      case StatutCommande.enAttente: return 'En attente';
      case StatutCommande.confirmee: return 'Confirmée';
      case StatutCommande.livree:    return 'Livrée';
      case StatutCommande.annulee:   return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CommandeController>(
      builder: (context, ctrl, _) {
        final commandes = _filter(ctrl.commandes);

        return LoadingOverlay(
          isLoading: ctrl.isLoading,
          message: 'Chargement...',
          child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FE),
            drawer: const AppDrawer(),
            floatingActionButton: _buildFAB(context),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, l10n, isDark),

                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _searchVisible ? 64 : 0,
                      child: _searchVisible
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: l10n.rechercher,
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () =>
                                              setState(() => _searchCtrl.clear()),
                                        )
                                      : null,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  SliverToBoxAdapter(child: _buildStatutFilters(isDark)),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        '${commandes.length} commande(s)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF7E7E9F)
                              : const Color(0xFF9E9EBF),
                        ),
                      ),
                    ),
                  ),

                  if (ctrl.isLoading && ctrl.commandes.isEmpty)
                    const SliverFillRemaining(child: ShimmerLoader(itemCount: 6))
                  else if (commandes.isEmpty)
                    SliverFillRemaining(
                      child: (_searchCtrl.text.isNotEmpty || _statutFilter != null)
                          ? EmptyState.search(_searchCtrl.text.isNotEmpty
                              ? _searchCtrl.text
                              : _statutLabel(_statutFilter!))
                          : EmptyState.commandes(
                              onAdd: () => context.push(AppRouter.commandeAdd),
                            ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _CommandeTile(
                          commande: commandes[i],
                          isDark: isDark,
                          avatarColor: _colorFor(commandes[i].clientNom),
                          onTap: () => context.push(
                            AppRouter.commandeDetail,
                            extra: commandes[i],
                          ),
                          onDelete: () => _confirmDelete(context, ctrl, commandes[i]),
                        ),
                        childCount: commandes.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n, bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FE),
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Text(
        l10n.commandes,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _searchVisible ? Icons.search_off_rounded : Icons.search_rounded,
              key: ValueKey(_searchVisible),
              color: isDark ? Colors.white70 : const Color(0xFF6E6E8F),
            ),
          ),
          onPressed: () {
            setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) _searchCtrl.clear();
            });
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStatutFilters(bool isDark) {
    final filters = <StatutCommande?>[null, ...StatutCommande.values];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = f == _statutFilter;
          final color = f == null ? AppTheme.primary : AppTheme.statutColor(f.value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _statutFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.15)
                      : (isDark ? const Color(0xFF1E1E30) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? color
                        : (isDark
                            ? const Color(0xFF2A2A40)
                            : const Color(0xFFEEEEF5)),
                  ),
                ),
                child: Text(
                  f == null ? 'Toutes' : _statutLabel(f),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? color
                        : (isDark
                            ? const Color(0xFF9E9EBF)
                            : const Color(0xFF6E6E8F)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
      return FloatingActionButton.extended(
      onPressed: () => context.push(AppRouter.commandeAdd),
      icon: const Icon(Icons.add_shopping_cart_rounded),
      label: Text(
        l10n.nouvelleCommande,
        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CommandeController ctrl,
    Commande commande,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer la commande',
      message:
          'Le stock des produits sera restauré. Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );
    if (confirmed && context.mounted) {
      final ok = await ctrl.deleteCommande(commande.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Commande supprimée' : ctrl.errorMessage),
            backgroundColor: ok ? AppTheme.success : AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Commande tile ───────────────────────────────────────────────────
class _CommandeTile extends StatelessWidget {
  final Commande commande;
  final bool isDark;
  final Color avatarColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CommandeTile({
    required this.commande,
    required this.isDark,
    required this.avatarColor,
    required this.onTap,
    required this.onDelete,
  });

  String _statutLabel(StatutCommande s) {
    switch (s) {
      case StatutCommande.enAttente: return 'En attente';
      case StatutCommande.confirmee: return 'Confirmée';
      case StatutCommande.livree:    return 'Livrée';
      case StatutCommande.annulee:   return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statutColor = AppTheme.statutColor(commande.statut.value);
    final dateStr = commande.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(commande.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(commande.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Supprimer',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E30) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A2A40) : const Color(0xFFEEEEF5),
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      commande.clientNom.isNotEmpty
                          ? commande.clientNom[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commande.clientNom,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr  •  ${commande.items.length} article(s)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF7E7E9F)
                              : const Color(0xFF9E9EBF),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      commande.total.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statutColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statutLabel(commande.statut),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statutColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}