   import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/produit_controller.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class ProduitFormScreen extends StatefulWidget {
  final Produit? produit;
  const ProduitFormScreen({super.key, this.produit});

  bool get isEditing => produit != null;

  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool  _loading = false;

  static const _categories = [
    'Électronique', 'Vêtements', 'Alimentation',
    'Maison',       'Beauté',    'Sport',
    'Informatique', 'Jouets',    'Autre',
  ];

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
                  initialValue: widget.produit != null
                      ? {
                          'nom':         widget.produit!.nom,
                          'prix':        widget.produit!.prix.toString(),
                          'stock':       widget.produit!.stock.toString(),
                          'categorie':   widget.produit!.categorie,
                          'description': widget.produit!.description,
                        }
                      : {},
                  child: Column(
                    children: [

                      // Nom
                      _FormField(
                        name:     'nom',
                        label:    l10n.nom,
                        hint:     'Ex: iPhone 15 Pro',
                        icon:     Icons.label_outline_rounded,
                        isDark:   isDark,
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Le nom est requis',
                          ),
                          FormBuilderValidators.minLength(2,
                            errorText: 'Minimum 2 caractères',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Prix + Stock (row)
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              name:      'prix',
                              label:     l10n.prix,
                              hint:      '0.00',
                              icon:      Icons.payments_outlined,
                              isDark:    isDark,
                              inputType: TextInputType.number,
                              suffix:    'MRU',
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Prix requis',
                                ),
                                FormBuilderValidators.numeric(
                                  errorText: 'Nombre invalide',
                                ),
                                FormBuilderValidators.min(0,
                                  errorText: 'Prix ≥ 0',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FormField(
                              name:      'stock',
                              label:     l10n.stock,
                              hint:      '0',
                              icon:      Icons.warehouse_outlined,
                              isDark:    isDark,
                              inputType: TextInputType.number,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Stock requis',
                                ),
                                FormBuilderValidators.integer(
                                  errorText: 'Entier requis',
                                ),
                                FormBuilderValidators.min(0,
                                  errorText: 'Stock ≥ 0',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Catégorie dropdown
                      _CategoryDropdown(
                        isDark:      isDark,
                        categories:  _categories,
                        l10n:        l10n,
                        initialValue: widget.produit?.categorie,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      _FormField(
                        name:      'description',
                        label:     'Description',
                        hint:      'Description du produit (optionnel)',
                        icon:      Icons.description_outlined,
                        isDark:    isDark,
                        maxLines:  4,
                        required:  false,
                        validators: [],
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      _SubmitButton(
                        isEdit:   isEdit,
                        loading:  _loading,
                        l10n:     l10n,
                        onTap:    () => _submit(context, l10n),
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
    final ctrl = context.read<ProduitController>();

    final produit = Produit(
      id:          widget.produit?.id,
      nom:         data['nom'] as String,
      prix:        double.parse(data['prix'] as String),
      stock:       int.parse(data['stock'] as String),
      categorie:   data['categorie'] as String?,
      description: data['description'] as String?,
      imageUrl:    widget.produit?.imageUrl,
      createdAt:   widget.produit?.createdAt ?? DateTime.now(),
    );

    final ok = widget.isEditing
        ? await ctrl.updateProduit(produit)
        : await ctrl.addProduit(produit);

    setState(() => _loading = false);

    if (context.mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Produit modifié avec succès'
                  : 'Produit ajouté avec succès',
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
          // Icon
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
                  : Icons.add_box_rounded,
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
                  isEdit ? 'Modifier le produit' : 'Nouveau produit',
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
          // Close button
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

// ── Reusable Form Field ────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String              name;
  final String              label;
  final String              hint;
  final IconData            icon;
  final bool                isDark;
  final TextInputType       inputType;
  final int                 maxLines;
  final bool                required;
  final String?             suffix;
  final List<String? Function(String?)> validators;

  const _FormField({
    required this.name,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.validators,
    this.inputType = TextInputType.text,
    this.maxLines  = 1,
    this.required  = true,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name:          name,
      keyboardType:  inputType,
      maxLines:      maxLines,
      validator:     FormBuilderValidators.compose(validators),
      decoration: InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        suffixStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? const Color(0xFF9E9EBF)
              : const Color(0xFF6E6E8F),
        ),
      ),
    );
  }
}

// ── Category Dropdown ──────────────────────────────────────────────
class _CategoryDropdown extends StatelessWidget {
  final bool          isDark;
  final List<String>  categories;
  final AppLocalizations l10n;
  final String?       initialValue;

  const _CategoryDropdown({
    required this.isDark,
    required this.categories,
    required this.l10n,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<String>(
      name:         'categorie',
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText:  l10n.categorie,
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'La catégorie est requise',
      ),
      items: categories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(
                  cat,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   14,
                  ),
                ),
              ))
          .toList(),
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