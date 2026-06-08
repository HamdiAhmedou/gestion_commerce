import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/produit_controller.dart';
import 'package:gestion_commerce/controllers/client_controller.dart';
import 'package:gestion_commerce/controllers/commande_controller.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/views/widgets/app_drawer.dart';
import 'package:gestion_commerce/views/widgets/loading_overlay.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitController>().loadProduits();
      context.read<ClientController>().loadClients();
      context.read<CommandeController>().loadCommandes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer3<ProduitController, ClientController, CommandeController>(
      builder: (context, prodCtrl, cliCtrl, cmdCtrl, _) {
        final isLoading =
            prodCtrl.isLoading || cliCtrl.isLoading || cmdCtrl.isLoading;

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
                  // ── AppBar ──────────────────────────────────────
                  _buildAppBar(context, isDark, l10n),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.horizontalPadding(context),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([

                        // ── Greeting ──────────────────────────────
                        _GreetingSection(isDark: isDark),
                        const SizedBox(height: 24),

                        // ── Stats Cards ───────────────────────────
                        _SectionTitle(
                          title: 'Vue d\'ensemble',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _StatsGrid(
                          prodCtrl: prodCtrl,
                          cliCtrl:  cliCtrl,
                          cmdCtrl:  cmdCtrl,
                          l10n:     l10n,
                          isDark:   isDark,
                        ),
                        const SizedBox(height: 24),

                        // ── Quick Actions ─────────────────────────
                        _SectionTitle(
                          title: 'Actions rapides',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          l10n:    l10n,
                          isDark:  isDark,
                          prodCtrl: prodCtrl,
                        ),
                        const SizedBox(height: 24),

                        // ── Stock Alert ───────────────────────────
                        _StockAlert(
                          prodCtrl: prodCtrl,
                          isDark:   isDark,
                        ),

                        // ── Recent Orders ─────────────────────────
                        _SectionTitle(
                          title: 'Commandes récentes',
                          isDark: isDark,
                          action: TextButton(
                            onPressed: () => context.go(AppRouter.commandes),
                            child: Text(
                              'Voir tout',
                              style: TextStyle(
                                fontFamily:  'Poppins',
                                fontSize:    13,
                                fontWeight:  FontWeight.w500,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _RecentOrders(
                          cmdCtrl: cmdCtrl,
                          isDark:  isDark,
                        ),

                        const SizedBox(height: 32),
                      ]),
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

  // ── Custom SliverAppBar ──────────────────────────────────────────
  Widget _buildAppBar(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      floating:        true,
      snap:            true,
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FE),
      elevation:       0,
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
        l10n.dashboard,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        // Notification bell
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white70 : const Color(0xFF6E6E8F),
              ),
              onPressed: () {},
            ),
            Positioned(
              top:   10,
              right: 10,
              child: Container(
                width:  8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Greeting Section ───────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final bool isDark;
  const _GreetingSection({required this.isDark});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour 👋';
    if (hour < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  String _formattedDate() {
    final now  = DateTime.now();
    final days = ['Lundi','Mardi','Mercredi','Jeudi',
                  'Vendredi','Samedi','Dimanche'];
    final months = ['Janvier','Février','Mars','Avril','Mai','Juin',
                    'Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withBlue(255).withRed(80),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:       AppTheme.primary.withOpacity(0.3),
            blurRadius:  20,
            offset:      const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   22,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formattedDate(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   13,
                    fontWeight: FontWeight.w400,
                    color:      Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color:  Colors.white.withOpacity(0.2),
              shape:  BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size:  28,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String  title;
  final bool    isDark;
  final Widget? action;
  const _SectionTitle({
    required this.title,
    required this.isDark,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   16,
            fontWeight: FontWeight.w700,
            color:      isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ── Stats Grid ─────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final ProduitController  prodCtrl;
  final ClientController   cliCtrl;
  final CommandeController cmdCtrl;
  final AppLocalizations   l10n;
  final bool isDark;

  const _StatsGrid({
    required this.prodCtrl,
    required this.cliCtrl,
    required this.cmdCtrl,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ca = cmdCtrl.commandes
        .fold<double>(0, (sum, c) => sum + c.total);

    final cards = [
      _StatData(
        label: l10n.totalProduits,
        value: '${prodCtrl.produits.length}',
        icon:  Icons.inventory_2_rounded,
        color: AppTheme.primary,
      ),
      _StatData(
        label: l10n.totalClients,
        value: '${cliCtrl.clients.length}',
        icon:  Icons.people_rounded,
        color: const Color(0xFF0BA5A5),
      ),
      _StatData(
        label: l10n.totalCommandes,
        value: '${cmdCtrl.commandes.length}',
        icon:  Icons.receipt_long_rounded,
        color: const Color(0xFFE07B4F),
      ),
      _StatData(
        label: l10n.chiffreAffaires,
        value: '${ca.toStringAsFixed(0)} MRU',
        icon:  Icons.trending_up_rounded,
        color: const Color(0xFF4CAF50),
      ),
    ];

    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 1.5,
      ),
      itemCount:   cards.length,
      itemBuilder: (_, i) => _StatCard(data: cards[i], isDark: isDark),
    );
  }
}

class _StatData {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  final bool      isDark;
  const _StatCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A40)
              : const Color(0xFFEEEEF5),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width:  38,
            height: 38,
            decoration: BoxDecoration(
              color:        data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          // Value + label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                data.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   11,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF7E7E9F)
                      : const Color(0xFF9E9EBF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ──────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final AppLocalizations   l10n;
  final bool               isDark;
  final ProduitController  prodCtrl;

  const _QuickActions({
    required this.l10n,
    required this.isDark,
    required this.prodCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        label: 'Nouveau produit',
        icon:  Icons.add_box_rounded,
        color: AppTheme.primary,
        onTap: () => context.push(AppRouter.produitAdd),
      ),
      _ActionData(
        label: 'Nouveau client',
        icon:  Icons.person_add_rounded,
        color: const Color(0xFF0BA5A5),
        onTap: () => context.push(AppRouter.clientAdd),
      ),
      _ActionData(
        label: 'Nouvelle commande',
        icon:  Icons.add_shopping_cart_rounded,
        color: const Color(0xFFE07B4F),
        onTap: () => context.push(AppRouter.commandeAdd),
      ),
      _ActionData(
        label: 'Importer API',
        icon:  Icons.cloud_download_rounded,
        color: const Color(0xFF4CAF50),
        onTap: () async {
          final ok = await prodCtrl.importFromApi();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok ? l10n.importSuccess : prodCtrl.errorMessage,
                ),
                backgroundColor: ok ? AppTheme.success : AppTheme.error,
                behavior:        SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 2.2,
      ),
      itemCount:   actions.length,
      itemBuilder: (_, i) => _ActionCard(data: actions[i], isDark: isDark),
    );
  }
}

class _ActionData {
  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;
  const _ActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;
  final bool        isDark;
  const _ActionCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap:        data.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: data.color.withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: data.color.withOpacity(isDark ? 0.3 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        data.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      data.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stock Alert ────────────────────────────────────────────────────
class _StockAlert extends StatelessWidget {
  final ProduitController prodCtrl;
  final bool isDark;
  const _StockAlert({required this.prodCtrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lowStock = prodCtrl.produits
        .where((p) => p.stock <= 5)
        .toList();

    if (lowStock.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Alertes stock',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.error.withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.error,
                      size:  18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${lowStock.length} produit(s) en stock faible',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              ...lowStock.take(3).map((p) => ListTile(
                dense: true,
                leading: Container(
                  width:  32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:        AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.error,
                    size:  16,
                  ),
                ),
                title: Text(
                  p.nom,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical:    4,
                  ),
                  decoration: BoxDecoration(
                    color:        AppTheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stock: ${p.stock}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                      color:      AppTheme.error,
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Recent Orders ──────────────────────────────────────────────────
class _RecentOrders extends StatelessWidget {
  final CommandeController cmdCtrl;
  final bool isDark;
  const _RecentOrders({required this.cmdCtrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recent = cmdCtrl.commandes.take(5).toList();

    if (recent.isEmpty) {
      return Container(
        padding:     const EdgeInsets.all(24),
        decoration:  BoxDecoration(
          color: isDark ? const Color(0xFF1E1E30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A40)
                : const Color(0xFFEEEEF5),
          ),
        ),
        child: Center(
          child: Text(
            'Aucune commande récente',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   13,
              color: isDark
                  ? const Color(0xFF7E7E9F)
                  : const Color(0xFF9E9EBF),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A40)
              : const Color(0xFFEEEEF5),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: recent.asMap().entries.map((entry) {
          final index = entry.key;
          final cmd   = entry.value;
          return Column(
            children: [
              if (index != 0)
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A2A40)
                      : const Color(0xFFEEEEF5),
                ),
              _OrderRow(cmd: cmd, isDark: isDark),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Commande cmd;
  final bool     isDark;
  const _OrderRow({required this.cmd, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statutColor(cmd.statut.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cmd.clientNom.isNotEmpty
                    ? cmd.clientNom[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   16,
                  fontWeight: FontWeight.w700,
                  color:      AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cmd.clientNom,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cmd.createdAt != null
                      ? '${cmd.createdAt!.day}/${cmd.createdAt!.month}/${cmd.createdAt!.year}'
                      : '—',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   11,
                    color: isDark
                        ? const Color(0xFF7E7E9F)
                        : const Color(0xFF9E9EBF),
                  ),
                ),
              ],
            ),
          ),

          // Total + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${cmd.total.toStringAsFixed(0)} MRU',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical:   2,
                ),
                decoration: BoxDecoration(
                  color:        statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cmd.statut.value.replaceAll('_', ' '),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   10,
                    fontWeight: FontWeight.w600,
                    color:      statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}