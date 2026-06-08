import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_commerce/app.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc    = Localizations.localeOf(context);
    final isAr   = loc.languageCode == 'ar';

    // current route
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      width: 290,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight:    Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [

            // ── Header ───────────────────────────────────────────
            _DrawerHeader(isDark: isDark, l10n: l10n),

            const SizedBox(height: 8),

            // ── Navigation items ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [

                  _SectionLabel(label: isAr ? 'القائمة' : 'MENU'),

                  _NavItem(
                    icon:      Icons.dashboard_rounded,
                    label:     l10n.dashboard,
                    isActive:  location == AppRouter.dashboard,
                    onTap:     () => _navigate(context, AppRouter.dashboard),
                    color:     AppTheme.primary,
                  ),
                  _NavItem(
                    icon:     Icons.inventory_2_rounded,
                    label:    l10n.produits,
                    isActive: location.startsWith('/produits'),
                    onTap:    () => _navigate(context, AppRouter.produits),
                    color:    const Color(0xFF7C5CBF),
                  ),
                  _NavItem(
                    icon:     Icons.people_rounded,
                    label:    l10n.clients,
                    isActive: location.startsWith('/clients'),
                    onTap:    () => _navigate(context, AppRouter.clients),
                    color:    const Color(0xFF0BA5A5),
                  ),
                  _NavItem(
                    icon:     Icons.receipt_long_rounded,
                    label:    l10n.commandes,
                    isActive: location.startsWith('/commandes'),
                    onTap:    () => _navigate(context, AppRouter.commandes),
                    color:    const Color(0xFFE07B4F),
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  _SectionLabel(
                    label: isAr ? 'الإعدادات' : 'PARAMÈTRES',
                  ),

                  // ── Language switcher ─────────────────────────
                  _LanguageTile(isDark: isDark, isAr: isAr),

                  // ── Theme toggle ──────────────────────────────
                  _ThemeTile(isDark: isDark, l10n: l10n),

                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────────
            _DrawerFooter(isDark: isDark),

          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop(); // close drawer first
    context.go(route);
  }
}

// ── Header ─────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  const _DrawerHeader({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withBlue(255).withRed(100),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo circle
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.2),
              shape:        BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.appTitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize:   20,
              fontWeight: FontWeight.w700,
              color:      Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'v1.0.0',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   11,
                fontWeight: FontWeight.w500,
                color:      Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Text(
        label,
        style: TextStyle(
          fontFamily:    'Poppins',
          fontSize:      10,
          fontWeight:    FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF6E6E8F)
              : const Color(0xFFAAAAAF),
        ),
      ),
    );
  }
}

// ── Nav Item ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;
  final Color    color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(isDark ? 0.2 : 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap:        onTap,
        dense:        true,
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  38,
          height: 38,
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.15)
                : isDark
                    ? const Color(0xFF252538)
                    : const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive
                ? color
                : isDark
                    ? const Color(0xFF6E6E8F)
                    : const Color(0xFF9E9EAF),
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? color
                : isDark
                    ? const Color(0xFFCCCCEE)
                    : const Color(0xFF3A3A5A),
          ),
        ),
        trailing: isActive
            ? Container(
                width:  6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}

// ── Language Tile ──────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  const _LanguageTile({required this.isDark, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252538)
            : const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A40)
              : const Color(0xFFEEEEF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                size:  18,
                color: isDark
                    ? const Color(0xFF9E9EBF)
                    : const Color(0xFF6E6E8F),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? 'اللغة' : 'Langue',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFCCCCEE)
                      : const Color(0xFF3A3A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LangButton(
                flag:     '🇫🇷',
                label:    'Français',
                isActive: !isAr,
                onTap:    () => App.setLocale(context, const Locale('fr')),
                isDark:   isDark,
              ),
              const SizedBox(width: 8),
              _LangButton(
                flag:     '🇸🇦',
                label:    'العربية',
                isActive: isAr,
                onTap:    () => App.setLocale(context, const Locale('ar')),
                isDark:   isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool   isActive;
  final VoidCallback onTap;
  final bool   isDark;

  const _LangButton({
    required this.flag,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? AppTheme.primary.withOpacity(0.4)
                  : isDark
                      ? const Color(0xFF3A3A55)
                      : const Color(0xFFDDDDEE),
            ),
          ),
          child: Column(
            children: [
              Text(flag,   style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppTheme.primary
                      : isDark
                          ? const Color(0xFF9E9EBF)
                          : const Color(0xFF6E6E8F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme Tile ─────────────────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  final bool             isDark;
  final AppLocalizations l10n;
  const _ThemeTile({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252538)
            : const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A40)
              : const Color(0xFFEEEEF5),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width:  38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A30)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: isDark
                ? const Color(0xFFFFC107)
                : const Color(0xFFFF9800),
            size: 20,
          ),
        ),
        title: Text(
          isDark ? 'Mode sombre' : 'Mode clair',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFFCCCCEE)
                : const Color(0xFF3A3A5A),
          ),
        ),
        trailing: Switch.adaptive(
          value:          isDark,
          activeColor:    AppTheme.primary,
          onChanged: (val) => App.setThemeMode(
            context,
            val ? ThemeMode.dark : ThemeMode.light,
          ),
        ),
      ),
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  final bool isDark;
  const _DrawerFooter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code_rounded,
            size:  14,
            color: isDark
                ? const Color(0xFF4A4A6A)
                : const Color(0xFFCCCCDD),
          ),
          const SizedBox(width: 6),
          Text(
            'Gestion Commerce © 2025',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   11,
              color: isDark
                  ? const Color(0xFF4A4A6A)
                  : const Color(0xFFCCCCDD),
            ),
          ),
        ],
      ),
    );
  }
}