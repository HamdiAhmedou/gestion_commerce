import 'package:flutter/material.dart';
import 'package:gestion_commerce/config/theme.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final String?  actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  // ── Named constructors for each screen ──────────────────────────
  factory EmptyState.produits({VoidCallback? onAdd}) => EmptyState(
        icon:        Icons.inventory_2_outlined,
        title:       'Aucun produit',
        subtitle:    'Ajoutez votre premier produit\nou importez depuis l\'API.',
        actionLabel: 'Ajouter un produit',
        onAction:    onAdd,
      );

  factory EmptyState.clients({VoidCallback? onAdd}) => EmptyState(
        icon:        Icons.people_outline_rounded,
        title:       'Aucun client',
        subtitle:    'Commencez par ajouter\nvotre premier client.',
        actionLabel: 'Ajouter un client',
        onAction:    onAdd,
      );

  factory EmptyState.commandes({VoidCallback? onAdd}) => EmptyState(
        icon:        Icons.receipt_long_outlined,
        title:       'Aucune commande',
        subtitle:    'Les commandes que vous créez\napparaîtront ici.',
        actionLabel: 'Créer une commande',
        onAction:    onAdd,
      );

  factory EmptyState.search(String query) => EmptyState(
        icon:     Icons.search_off_rounded,
        title:    'Aucun résultat',
        subtitle: 'Aucun élément ne correspond\nà "$query".',
      );

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;
  late final Animation<double>    _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Animated icon circle ─────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF252538)
                          : const Color(0xFFF0F0FA),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E2E45)
                            : const Color(0xFFE5E5F5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size:  48,
                      color: AppTheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title ────────────────────────────────────────
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ─────────────────────────────────────
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFF7E7E9F)
                        : const Color(0xFF9E9EBF),
                    height: 1.6,
                  ),
                ),

                // ── Action button ─────────────────────────────────
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon:  const Icon(Icons.add_rounded, size: 20),
                    label: Text(widget.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}