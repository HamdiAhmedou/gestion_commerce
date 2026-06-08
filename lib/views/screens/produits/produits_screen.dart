import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/produit_controller.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/views/widgets/app_drawer.dart';
import 'package:gestion_commerce/views/widgets/empty_state.dart';
import 'package:gestion_commerce/views/widgets/loading_overlay.dart';
import 'package:gestion_commerce/views/widgets/confirm_dialog.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({super.key});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  final _searchCtrl     = TextEditingController();
  String _selectedCat   = 'Tous';
  bool   _searchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitController>().loadProduits();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Produit> _filtered(List<Produit> all) {
    var list = all;
    if (_selectedCat != 'Tous') {
      list = list.where((p) => p.categorie == _selectedCat).toList();
    }
    return list;
  }

  List<String> _categories(List<Produit> all) {
    final cats = all
        .map((p) => p.categorie ?? 'Autre')
        .toSet()
        .toList()
      ..sort();
    return ['Tous', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProduitController>(
      builder: (context, ctrl, _) {
        final displayed = _filtered(ctrl.produits);
        final categories = _categories(ctrl.produits);

        return LoadingOverlay(
          isLoading: ctrl.isLoading,
          message:   'Chargement...',
          child: Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0F0F1A)
                : const Color(0xFFF8F9FE),
            drawer: const AppDrawer(),
            floatingActionButton: _buildFAB(context, l10n),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [

                  // ── AppBar ──────────────────────────────────────
                  _buildAppBar(context, ctrl, l10n, isDark),

                  // ── Search bar ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height:   _searchVisible ? 64 : 0,
                      child: _searchVisible
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextField(
                                controller:  _searchCtrl,
                                autofocus:   true,
                                onChanged:   ctrl.search,
                                decoration: InputDecoration(
                                  hintText:    l10n.rechercher,
                                  prefixIcon:  const Icon(Icons.search_rounded),
                                  suffixIcon: _searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            ctrl.search('');
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // ── Filter chips ────────────────────────────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:   categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat      = categories[i];
                          final isActive = _selectedCat == cat;
                          return FilterChip(
                            label: Text(cat),
                            selected:  isActive,
                            onSelected: (_) =>
                                setState(() => _selectedCat = cat),
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E30)
                                : Colors.white,
                            selectedColor:
                                AppTheme.primary.withOpacity(0.15),
                            checkmarkColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize:   12,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? AppTheme.primary
                                  : isDark
                                      ? const Color(0xFFBBBBDD)
                                      : const Color(0xFF6E6E8F),
                            ),
                            side: BorderSide(
                              color: isActive
                                  ? AppTheme.primary.withOpacity(0.4)
                                  : isDark
                                      ? const Color(0xFF2A2A40)
                                      : const Color(0xFFEEEEF5),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ── Counter ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical:    4,
                      ),
                      child: Text(
                        '${displayed.length} produit(s)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize:   12,
                          color: isDark
                              ? const Color(0xFF7E7E9F)
                              : const Color(0xFF9E9EBF),
                        ),
                      ),
                    ),
                  ),

                  // ── List / Empty ─────────────────────────────────
                  if (ctrl.isLoading && ctrl.produits.isEmpty)
                    const SliverFillRemaining(
                      child: ShimmerLoader(itemCount: 6),
                    )
                  else if (displayed.isEmpty)
                    SliverFillRemaining(
                      child: _searchCtrl.text.isNotEmpty
                          ? EmptyState.search(_searchCtrl.text)
                          : EmptyState.produits(
                              onAdd: () =>
                                  context.push(AppRouter.produitAdd),
                            ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ProduitTile(
                          produit: displayed[i],
                          isDark:  isDark,
                          onEdit: () => context.push(
                            AppRouter.produitEdit,
                            extra: displayed[i],
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            ctrl,
                            displayed[i],
                            l10n,
                          ),
                        ),
                        childCount: displayed.length,
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

  // ── AppBar ───────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    ProduitController ctrl,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return SliverAppBar(
      floating:        true,
      snap:            true,
      backgroundColor: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF8F9FE),
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
        l10n.produits,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        // Search toggle
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _searchVisible
                  ? Icons.search_off_rounded
                  : Icons.search_rounded,
              key:   ValueKey(_searchVisible),
              color: isDark ? Colors.white70 : const Color(0xFF6E6E8F),
            ),
          ),
          onPressed: () {
            setState(() => _searchVisible = !_searchVisible);
            if (!_searchVisible) {
              _searchCtrl.clear();
              ctrl.search('');
            }
          },
        ),
        // Import API
        IconButton(
          tooltip: l10n.importerApi,
          icon: Icon(
            Icons.cloud_download_rounded,
            color: isDark ? Colors.white70 : const Color(0xFF6E6E8F),
          ),
          onPressed: () => _importFromApi(context, ctrl, l10n),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed:  () => context.push(AppRouter.produitAdd),
      icon:       const Icon(Icons.add_rounded),
      label:      Text(
        l10n.ajouter,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation:       4,
    );
  }

  // ── Delete confirm ───────────────────────────────────────────────
  Future<void> _confirmDelete(
    BuildContext context,
    ProduitController ctrl,
    Produit produit,
    AppLocalizations l10n,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:       'Supprimer le produit',
      message:     'Voulez-vous supprimer "${produit.nom}" ? Cette action est irréversible.',
      confirmText: l10n.supprimer,
      cancelText:  l10n.annuler,
    );
    if (confirmed && context.mounted) {
      final ok = await ctrl.deleteProduit(produit.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Produit supprimé' : ctrl.errorMessage,
            ),
            backgroundColor: ok ? AppTheme.success : AppTheme.error,
            behavior:        SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Import API ───────────────────────────────────────────────────
  Future<void> _importFromApi(
    BuildContext context,
    ProduitController ctrl,
    AppLocalizations l10n,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:        l10n.importerApi,
      message:      'Cette action importera des produits depuis DummyJSON API et les ajoutera à votre catalogue.',
      confirmText:  'Importer',
      cancelText:   l10n.annuler,
      icon:         Icons.cloud_download_rounded,
      confirmColor: AppTheme.info,
    );
    if (confirmed && context.mounted) {
      final ok = await ctrl.importFromApi();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? l10n.importSuccess : ctrl.errorMessage,
            ),
            backgroundColor: ok ? AppTheme.success : AppTheme.error,
            behavior:        SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Produit Tile ───────────────────────────────────────────────────
class _ProduitTile extends StatelessWidget {
  final Produit      produit;
  final bool         isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProduitTile({
    required this.produit,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = produit.stock <= 5
        ? AppTheme.error
        : produit.stock <= 20
            ? AppTheme.warning
            : AppTheme.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key:       ValueKey(produit.id),
        startActionPane: ActionPane(
          motion:   const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.info,
              foregroundColor: Colors.white,
              icon:             Icons.edit_rounded,
              label:            'Modifier',
              borderRadius:     BorderRadius.circular(16),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion:   const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon:             Icons.delete_rounded,
              label:            'Supprimer',
              borderRadius:     BorderRadius.circular(16),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A2A40)
                  : const Color(0xFFEEEEF5),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color:      Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset:     const Offset(0, 3),
                    ),
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical:    8,
            ),
            leading: _ProduitAvatar(produit: produit, isDark: isDark),
            title: Text(
              produit.nom,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (produit.categorie != null)
                  Text(
                    produit.categorie!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize:   11,
                      color: isDark
                          ? const Color(0xFF7E7E9F)
                          : const Color(0xFF9E9EBF),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${produit.prix.toStringAsFixed(2)} MRU',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      AppTheme.primary,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Stock badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical:    4,
                  ),
                  decoration: BoxDecoration(
                    color:        stockColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stock: ${produit.stock}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                      color:      stockColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF4A4A6A)
                        : const Color(0xFFCCCCDD),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Produit Avatar ─────────────────────────────────────────────────
class _ProduitAvatar extends StatelessWidget {
  final Produit produit;
  final bool    isDark;
  const _ProduitAvatar({required this.produit, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (produit.imageUrl != null && produit.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          produit.imageUrl!,
          width:  52,
          height: 52,
          fit:    BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width:  52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252538)
            : const Color(0xFFF0F0FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppTheme.primary.withOpacity(0.5),
        size:  24,
      ),
    );
  }
}