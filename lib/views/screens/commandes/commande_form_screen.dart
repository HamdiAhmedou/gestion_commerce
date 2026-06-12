import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_commerce/controllers/commande_controller.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class CommandeFormScreen extends StatefulWidget {
  final Commande? commande;
  const CommandeFormScreen({super.key, this.commande});

  bool get isEditing => commande != null;

  @override
  State<CommandeFormScreen> createState() => _CommandeFormScreenState();
}

class _CommandeFormScreenState extends State<CommandeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNomCtrl;
  late TextEditingController _totalCtrl;
  late StatutCommande _statut;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _clientNomCtrl = TextEditingController(
      text: widget.commande?.clientNom ?? '',
    );
    _totalCtrl = TextEditingController(
      text: widget.commande?.total.toString() ?? '',
    );
    _statut = widget.commande?.statut ?? StatutCommande.enAttente;
  }

  @override
  void dispose() {
    _clientNomCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.isEditing;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1A1A24) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Modifier Commande' : 'Nouvelle Commande',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Client Nom
                      TextFormField(
                        controller: _clientNomCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nom du client',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Total
                      TextFormField(
                        controller: _totalCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Total (MRU)',
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Statut
                      DropdownButtonFormField<StatutCommande>(
                        value: _statut,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _statut = value);
                          }
                        },
                        items: StatutCommande.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statutLabel(s)),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: const Icon(Icons.info_outline),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Actions ──────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              child: Text(l10n.annuler),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: _loading ? null : _onSubmit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEdit ? l10n.modifier : l10n.confirmer,
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
          ],
        ),
      ),
    );
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final ctrl = context.read<CommandeController>();
      final clientNom = _clientNomCtrl.text;
      final total = double.parse(_totalCtrl.text);

      if (widget.isEditing) {
        // Update statut
        await ctrl.updateStatut(widget.commande!.id ?? '', _statut);
      } else {
        // Create new
        final commande = Commande(
          clientId: '',
          clientNom: clientNom,
          total: total,
          statut: _statut,
        );
        await ctrl.addCommande(commande);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _statutLabel(StatutCommande statut) {
    switch (statut) {
      case StatutCommande.enAttente:
        return 'En attente';
      case StatutCommande.confirmee:
        return 'Confirmée';
      case StatutCommande.livree:
        return 'Livrée';
      case StatutCommande.annulee:
        return 'Annulée';
    }
  }
}
