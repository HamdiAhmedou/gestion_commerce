import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gestion_commerce/config/router.dart';
import 'package:gestion_commerce/config/theme.dart';
import 'package:gestion_commerce/controllers/produit_controller.dart';
import 'package:gestion_commerce/controllers/client_controller.dart';
import 'package:gestion_commerce/controllers/commande_controller.dart';
import 'package:gestion_commerce/l10n/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  // Global locale switcher — call App.setLocale(context, Locale('ar'))
  static void setLocale(BuildContext context, Locale locale) {
    _AppState? state = context.findAncestorStateOfType<_AppState>();
    state?.setLocale(locale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    _AppState? state = context.findAncestorStateOfType<_AppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale    _locale    = const Locale('fr');
  ThemeMode _themeMode = ThemeMode.light;

  void setLocale(Locale locale) => setState(() => _locale = locale);
  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProduitController()),
        ChangeNotifierProvider(create: (_) => ClientController()),
        ChangeNotifierProvider(create: (_) => CommandeController()),
      ],
      child: MaterialApp.router(
        title: 'Gestion Commerce',
        debugShowCheckedModeBanner: false,

        // Themes
        theme:      AppTheme.light(),
        darkTheme:  AppTheme.dark(),
        themeMode:  _themeMode,

        // Router
        routerConfig: AppRouter.router,

        // Internationalisation
        locale: _locale,
        supportedLocales: const [Locale('fr'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // RTL support for Arabic
        builder: (context, child) {
          return Directionality(
            textDirection: _locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          );
        },
      ),
    );
  }
}