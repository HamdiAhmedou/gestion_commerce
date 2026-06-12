import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/client_controller.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/views/widgets/app_drawer.dart';
import 'package:gestion_commerce/views/widgets/empty_state.dart';
import 'package:gestion_commerce/views/widgets/loading_overlay.dart';
import 'package:gestion_commerce/views/widgets/confirm_dialog.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl     = TextEditingController();
  bool  _searchVisible  = false;

  // Color palette for avatars (cycles based on name)
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
      context.read<ClientController>().loadClients();
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

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ClientController>(
      builder: (context, ctrl, _) {
        final clients = ctrl.clients;

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
                                controller: _searchCtrl,
                                autofocus:  true,
                                onChanged:  ctrl.search,
                                decoration: InputDecoration(
                                  hintText:   l10n.rechercher,
                                  prefixIcon: const Icon(Icons.search_rounded),
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

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ── Counter ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical:    4,
                      ),
                      child: Text(
                        '${clients.length} client(s)',
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
                  if (ctrl.isLoading && ctrl.clients.isEmpty)
                    const SliverFillRemaining(
                      child: ShimmerLoader(itemCount: 6),
                    )
                  else if (clients.isEmpty)
                    SliverFillRemaining(
                      child: _searchCtrl.text.isNotEmpty
                          ? EmptyState.search(_searchCtrl.text)
                          : EmptyState.clients(
                              onAdd: () =>
                                  context.push(AppRouter.clientAdd),
                            ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ClientTile(
                          client:     clients[i],
                          isDark:     isDark,
                          avatarColor: _colorFor(clients[i].nom),
                          onEdit: () => context.push(
                            AppRouter.clientEdit,
                            extra: clients[i],
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            ctrl,
                            clients[i],
                            l10n,
                          ),
                        ),
                        childCount: clients.length,
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
    ClientController ctrl,
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
        l10n.clients,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      actions: [
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
        const SizedBox(width: 4),
      ],
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => context.push(AppRouter.clientAdd),
      icon:      const Icon(Icons.person_add_rounded),
      label: Text(
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
    ClientController ctrl,
    Client client,
    AppLocalizations l10n,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:       'Supprimer le client',
      message:     'Voulez-vous supprimer "${client.nom}" ? Cette action est irréversible.',
      confirmText: l10n.supprimer,
      cancelText:  l10n.annuler,
    );
    if (confirmed && context.mounted) {
      final ok = await ctrl.deleteClient(client.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Client supprimé' : ctrl.errorMessage,
            ),
            backgroundColor: ok ? AppTheme.success : AppTheme.error,
            behavior:        SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Client Tile ────────────────────────────────────────────────────
class _ClientTile extends StatelessWidget {
  final Client       client;
  final bool         isDark;
  final Color        avatarColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientTile({
    required this.client,
    required this.isDark,
    required this.avatarColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(client.id),
        startActionPane: ActionPane(
          motion:      const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed:       (_) => onEdit(),
              backgroundColor: AppTheme.info,
              foregroundColor: Colors.white,
              icon:            Icons.edit_rounded,
              label:           'Modifier',
              borderRadius:    BorderRadius.circular(16),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion:      const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed:       (_) => onDelete(),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon:            Icons.delete_rounded,
              label:           'Supprimer',
              borderRadius:    BorderRadius.circular(16),
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
            leading: Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color:        avatarColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  client.nom.isNotEmpty
                      ? client.nom[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   18,
                    fontWeight: FontWeight.w700,
                    color:      avatarColor,
                  ),
                ),
              ),
            ),
            title: Text(
              client.nom,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (client.email != null && client.email!.isNotEmpty)
                    _InfoRow(
                      icon:   Icons.email_outlined,
                      text:   client.email!,
                      isDark: isDark,
                    ),
                  if (client.telephone != null && client.telephone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _InfoRow(
                        icon:   Icons.phone_outlined,
                        text:   client.telephone!,
                        isDark: isDark,
                      ),
                    ),
                ],
              ),
            ),
            trailing: GestureDetector(
              onTap: onEdit,
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? const Color(0xFF4A4A6A)
                    : const Color(0xFFCCCCDD),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Info Row (email/phone) ─────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final bool     isDark;
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size:  13,
          color: isDark
              ? const Color(0xFF7E7E9F)
              : const Color(0xFF9E9EBF),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   12,
              color: isDark
                  ? const Color(0xFF7E7E9F)
                  : const Color(0xFF9E9EBF),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}