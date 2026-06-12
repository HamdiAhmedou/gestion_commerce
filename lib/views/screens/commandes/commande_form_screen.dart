import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/client_controller.dart';
import 'package:gestion_commerce/controllers/commande_controller.dart';
import 'package:gestion_commerce/controllers/produit_controller.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/models/commande_item.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/views/widgets/confirm_dialog.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

// ── Draft line item (create mode only) ─────────────────────────────
class _DraftItem {
  final Produit produit;
  int quantite;
  _DraftItem({required this.produit, this.quantite = 1});
  double get sousTotal => produit.prix * quantite;
}

class CommandeFormScreen extends StatefulWidget {
  final Commande? commande;
  const CommandeFormScreen({super.key, this.commande});

  bool get isViewing => commande != null;

  @override
  State<CommandeFormScreen> createState() => _CommandeFormScreenState();
}

class _CommandeFormScreenState extends State<CommandeFormScreen> {
  Client? _selectedClient;
  final List<_DraftItem> _draftItems = [];
  StatutCommande? _statut;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isViewing) {
      _statut = widget.commande!.statut;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ClientController>().loadClients();
        context.read<ProduitController>().loadProduits();
      });
    }
  }

  double get _total {
    if (widget.isViewing) return widget.commande!.total;
    return _draftItems.fold(0.0, (sum, d) => sum + d.sousTotal);
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isView = widget.isViewing;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _FormHeader(isView: isView, isDark: isDark, commande: widget.commande),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClientSection(context, isDark, isView),
                    const SizedBox(height: 24),
                    _buildProductsSection(context, isDark, isView),
                    const SizedBox(height: 24),
                    _buildTotalRow(isDark),
                    if (isView) ...[
                      const SizedBox(height: 24),
                      _buildStatutSection(context, isDark),
                      const SizedBox(height: 24),
                      _buildDeleteButton(context),
                    ] else ...[
                      const SizedBox(height: 32),
                      _buildSubmitButton(context, l10n),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Client section ────────────────────────────────────────────
  Widget _buildClientSection(BuildContext context, bool isDark, bool isView) {
    final name = isView ? widget.commande!.clientNom : _selectedClient?.nom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Client', isDark: isDark),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isView ? null : () => _showClientPicker(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(isDark),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name ?? 'Sélectionner un client',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: name == null
                          ? (isDark
                              ? const Color(0xFF6E6E8F)
                              : const Color(0xFF9E9EBF))
                          : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                  ),
                ),
                if (!isView)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF4A4A6A)
                        : const Color(0xFFCCCCDD),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Products section ──────────────────────────────────────────
  Widget _buildProductsSection(BuildContext context, bool isDark, bool isView) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(title: 'Produits', isDark: isDark),
            if (!isView)
              TextButton.icon(
                onPressed: () => _showProductPicker(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Ajouter'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (isView)
          if (widget.commande!.items.isEmpty)
            _emptyHint(isDark, 'Aucun article')
          else
            ...widget.commande!.items.map((item) => _ItemRow(
                  isDark: isDark,
                  nom: item.produitNom,
                  quantite: item.quantite,
                  prixUnitaire: item.prixUnitaire,
                  sousTotal: item.sousTotal,
                ))
        else if (_draftItems.isEmpty)
          _emptyHint(isDark, 'Aucun produit ajouté')
        else
          ..._draftItems.map((d) => _DraftItemRow(
                isDark: isDark,
                draft: d,
                onIncrement: d.quantite < d.produit.stock
                    ? () => setState(() => d.quantite++)
                    : null,
                onDecrement: d.quantite > 1
                    ? () => setState(() => d.quantite--)
                    : null,
                onRemove: () => setState(() => _draftItems.remove(d)),
              )),
      ],
    );
  }

  Widget _emptyHint(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: _cardDecoration(isDark),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: isDark ? const Color(0xFF6E6E8F) : const Color(0xFF9E9EBF),
        ),
      ),
    );
  }

  // ── Total row ─────────────────────────────────────────────────
  Widget _buildTotalRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            _fmt(_total),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Statut section (view mode) ──────────────────────────────────
  Widget _buildStatutSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Statut', isDark: isDark),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StatutCommande.values.map((s) {
            final selected = s == _statut;
            final color = AppTheme.statutColor(s.value);
            return GestureDetector(
              onTap: _loading || selected ? null : () => _changeStatut(context, s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  _statutLabel(s),
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
            );
          }).toList(),
        ),
      ],
    );
  }

  String _statutLabel(StatutCommande s) {
    switch (s) {
      case StatutCommande.enAttente: return 'En attente';
      case StatutCommande.confirmee: return 'Confirmée';
      case StatutCommande.livree:    return 'Livrée';
      case StatutCommande.annulee:   return 'Annulée';
    }
  }

  Future<void> _changeStatut(BuildContext context, StatutCommande s) async {
    if (s == StatutCommande.annulee) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Annuler la commande',
        message: 'Le stock des produits sera restauré. Continuer ?',
        confirmText: 'Annuler la commande',
        cancelText: 'Retour',
        icon: Icons.cancel_outlined,
      );
      if (!confirmed) return;
    }

    setState(() => _loading = true);
    final ctrl = context.read<CommandeController>();
    final ok = await ctrl.updateStatut(widget.commande!.id!, s);
    setState(() => _loading = false);

    if (ok) setState(() => _statut = s);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Statut mis à jour' : ctrl.errorMessage),
          backgroundColor: ok ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Delete (view mode) ────────────────────────────────────────
  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmDelete(context),
        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
        label: const Text('Supprimer la commande',
            style: TextStyle(color: AppTheme.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer la commande',
      message:
          'Le stock des produits sera restauré. Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );
    if (!confirmed || !context.mounted) return;

    setState(() => _loading = true);
    final ctrl = context.read<CommandeController>();
    final ok = await ctrl.deleteCommande(widget.commande!.id!);
    setState(() => _loading = false);

    if (context.mounted) {
      if (ok) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ctrl.errorMessage),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Submit (create mode) ─────────────────────────────────────
  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    final canSubmit =
        _selectedClient != null && _draftItems.isNotEmpty && !_loading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submit(context) : null,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.ajouter,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    setState(() => _loading = true);

    final items = _draftItems
        .map((d) => CommandeItem(
              commandeId: '',
              produitId: d.produit.id!,
              produitNom: d.produit.nom,
              quantite: d.quantite,
              prixUnitaire: d.produit.prix,
            ))
        .toList();

    final commande = Commande(
      clientId: _selectedClient!.id!,
      clientNom: _selectedClient!.nom,
      total: _total,
      items: items,
      createdAt: DateTime.now(),
    );

    final ctrl = context.read<CommandeController>();
    final ok = await ctrl.addCommande(commande);

    setState(() => _loading = false);

    if (context.mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande créée avec succès'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ctrl.errorMessage),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Client picker ────────────────────────────────────────────
  void _showClientPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet<Client>(
        title: 'Sélectionner un client',
        items: context.read<ClientController>().clients,
        searchHint: 'Rechercher un client...',
        filter: (c, q) => c.nom.toLowerCase().contains(q.toLowerCase()),
        itemBuilder: (c, isDark) => _PickerTile(
          leadingIcon: Icons.person_outline_rounded,
          title: c.nom,
          subtitle: c.telephone ?? c.email,
          isDark: isDark,
        ),
        onSelect: (c) => setState(() => _selectedClient = c),
      ),
    );
  }

  // ── Product picker ───────────────────────────────────────────
  void _showProductPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet<Produit>(
        title: 'Sélectionner un produit',
        items: context.read<ProduitController>().produits,
        searchHint: 'Rechercher un produit...',
        filter: (p, q) => p.nom.toLowerCase().contains(q.toLowerCase()),
        itemBuilder: (p, isDark) => _PickerTile(
          leadingIcon: Icons.inventory_2_outlined,
          title: p.nom,
          subtitle: '${_fmt(p.prix)}  •  Stock: ${p.stock}',
          isDark: isDark,
        ),
        isDisabled: (p) => p.stock <= 0,
        onSelect: (p) => _addProduct(context, p),
      ),
    );
  }

  void _addProduct(BuildContext context, Produit p) {
    final existing = _draftItems.where((d) => d.produit.id == p.id);
    if (existing.isNotEmpty) {
      final d = existing.first;
      if (d.quantite < p.stock) {
        setState(() => d.quantite++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock maximum atteint'),
            backgroundColor: AppTheme.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _draftItems.add(_DraftItem(produit: p)));
    }
  }
}

// ── Shared card decoration ────────────────────────────────────────
BoxDecoration _cardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? const Color(0xFF1E1E30) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? const Color(0xFF2A2A40) : const Color(0xFFEEEEF5),
    ),
  );
}

// ── Section title ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFF9E9EBF) : const Color(0xFF6E6E8F),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────
class _FormHeader extends StatelessWidget {
  final bool isView;
  final bool isDark;
  final Commande? commande;
  const _FormHeader({required this.isView, required this.isDark, this.commande});

  @override
  Widget build(BuildContext context) {
    final dateStr = commande?.createdAt != null
        ? DateFormat('dd/MM/yyyy à HH:mm').format(commande!.createdAt!)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isView ? Icons.receipt_long_rounded : Icons.add_shopping_cart_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isView ? 'Commande' : 'Nouvelle',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF7E7E9F)
                        : const Color(0xFF9E9EBF),
                  ),
                ),
                Text(
                  isView ? (dateStr ?? 'Détails de la commande') : 'Nouvelle commande',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? const Color(0xFF7E7E9F) : const Color(0xFF9E9EBF),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Read-only item row (view mode) ──────────────────────────────────
class _ItemRow extends StatelessWidget {
  final bool isDark;
  final String nom;
  final int quantite;
  final double prixUnitaire;
  final double sousTotal;

  const _ItemRow({
    required this.isDark,
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
    required this.sousTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(isDark),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantite x ${prixUnitaire.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isDark ? const Color(0xFF7E7E9F) : const Color(0xFF9E9EBF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            sousTotal.toStringAsFixed(2),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Draft item row (create mode, with stepper) ───────────────────────
class _DraftItemRow extends StatelessWidget {
  final bool isDark;
  final _DraftItem draft;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback onRemove;

  const _DraftItemRow({
    required this.isDark,
    required this.draft,
    this.onIncrement,
    this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(isDark),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.produit.nom,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${draft.produit.prix.toStringAsFixed(2)}  •  ${draft.sousTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isDark ? const Color(0xFF7E7E9F) : const Color(0xFF9E9EBF),
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement, isDark: isDark),
          SizedBox(
            width: 32,
            child: Text(
              '${draft.quantite}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrement, isDark: isDark),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  const _StepperButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? const Color(0xFF252538) : const Color(0xFFF5F5FA))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? AppTheme.primary
              : (isDark ? const Color(0xFF3A3A55) : const Color(0xFFD5D5E5)),
        ),
      ),
    );
  }
}

// ── Generic searchable picker bottom sheet ───────────────────────────
class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String searchHint;
  final bool Function(T, String) filter;
  final Widget Function(T, bool isDark) itemBuilder;
  final bool Function(T)? isDisabled;
  final ValueChanged<T> onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.searchHint,
    required this.filter,
    required this.itemBuilder,
    this.isDisabled,
    required this.onSelect,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items.where((i) => widget.filter(i, _query)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A40) : const Color(0xFFEEEEF5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun résultat',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark
                                ? const Color(0xFF7E7E9F)
                                : const Color(0xFF9E9EBF),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final disabled = widget.isDisabled?.call(item) ?? false;
                          return Opacity(
                            opacity: disabled ? 0.4 : 1.0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: disabled
                                  ? null
                                  : () {
                                      widget.onSelect(item);
                                      Navigator.of(context).pop();
                                    },
                              child: widget.itemBuilder(item, isDark),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Picker tile ──────────────────────────────────────────────────────
class _PickerTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final bool isDark;

  const _PickerTile({
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(leadingIcon, color: AppTheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: isDark ? const Color(0xFF7E7E9F) : const Color(0xFF9E9EBF),
                ),
              )
            : null,
      ),
    );
  }
}