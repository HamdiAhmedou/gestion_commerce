import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/client_controller.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  bool get isEditing => client != null;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool  _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
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
            _FormHeader(isEdit: isEdit, isDark: isDark, l10n: l10n),

            // ── Form ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: widget.client != null
                      ? {
                          'nom':       widget.client!.nom,
                          'email':     widget.client!.email,
                          'telephone': widget.client!.telephone,
                          'adresse':   widget.client!.adresse,
                        }
                      : {},
                  child: Column(
                    children: [

                      // Nom
                      FormBuilderTextField(
                        name: 'nom',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Le nom est requis',
                          ),
                          FormBuilderValidators.minLength(2,
                            errorText: 'Minimum 2 caractères',
                          ),
                        ]),
                        decoration: InputDecoration(
                          labelText:  l10n.nom,
                          hintText:   'Ex: Ahmed Ould Mohamed',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      FormBuilderTextField(
                        name: 'email',
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.email(
                            errorText: 'Email invalide',
                          ),
                        ]),
                        decoration: InputDecoration(
                          labelText:  l10n.email,
                          hintText:   'exemple@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Téléphone
                      FormBuilderTextField(
                        name: 'telephone',
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.match(
                            RegExp(r'^[0-9+\s-]{8,15}$'),
                            errorText: 'Numéro de téléphone invalide',
                          ),
                        ]),
                        decoration: InputDecoration(
                          labelText:  l10n.telephone,
                          hintText:   'Ex: +222 12 34 56 78',
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Adresse
                      FormBuilderTextField(
                        name:     'adresse',
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText:  l10n.adresse,
                          hintText:   'Adresse complète (optionnel)',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit
                      _SubmitButton(
                        isEdit:  isEdit,
                        loading: _loading,
                        l10n:    l10n,
                        onTap:   () => _submit(context, l10n),
                      ),

                      const SizedBox(height: 16),
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

  // ── Submit ───────────────────────────────────────────────────────
  Future<void> _submit(
      BuildContext context, AppLocalizations l10n) async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _loading = true);

    final data = _formKey.currentState!.value;
    final ctrl = context.read<ClientController>();

    final client = Client(
      id:        widget.client?.id,
      nom:       data['nom'] as String,
      email:     (data['email'] as String?)?.isEmpty ?? true
          ? null
          : data['email'] as String,
      telephone: (data['telephone'] as String?)?.isEmpty ?? true
          ? null
          : data['telephone'] as String,
      adresse:   (data['adresse'] as String?)?.isEmpty ?? true
          ? null
          : data['adresse'] as String,
      createdAt: widget.client?.createdAt ?? DateTime.now(),
    );

    final ok = widget.isEditing
        ? await ctrl.updateClient(client)
        : await ctrl.addClient(client);

    setState(() => _loading = false);

    if (context.mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Client modifié avec succès'
                  : 'Client ajouté avec succès',
            ),
            backgroundColor: AppTheme.success,
            behavior:        SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text(ctrl.errorMessage),
            backgroundColor: AppTheme.error,
            behavior:        SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Form Header ────────────────────────────────────────────────────
class _FormHeader extends StatelessWidget {
  final bool isEdit;
  final bool isDark;
  final AppLocalizations l10n;
  const _FormHeader({
    required this.isEdit,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  48,
            height: 48,
            decoration: BoxDecoration(
              color:        AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEdit
                  ? Icons.edit_rounded
                  : Icons.person_add_rounded,
              color: AppTheme.primary,
              size:  24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? l10n.modifier : l10n.ajouter,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF7E7E9F)
                        : const Color(0xFF9E9EBF),
                  ),
                ),
                Text(
                  isEdit ? 'Modifier le client' : 'Nouveau client',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   18,
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
              color: isDark
                  ? const Color(0xFF7E7E9F)
                  : const Color(0xFF9E9EBF),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Submit Button ──────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool         isEdit;
  final bool         loading;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isEdit,
    required this.loading,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(
                width:  22,
                height: 22,
                child:  CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:       Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEdit
                        ? Icons.save_rounded
                        : Icons.add_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? l10n.enregistrer : l10n.ajouter,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize:   16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}