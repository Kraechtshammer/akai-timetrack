import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../ui/home_shell.dart';
import '../ui/onboarding/onboarding_screen.dart';
import 'providers.dart';
import 'theme.dart';

class TimeTrackApp extends ConsumerWidget {
  const TimeTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(settingsProvider).value;
    final settings = ref.settings;
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(
          schemeFor(settings.themeSeed, Brightness.light, lightDynamic),
        ),
        darkTheme: buildTheme(
          schemeFor(settings.themeSeed, Brightness.dark, darkDynamic),
        ),
        themeMode: themeModeFor(settings.themeMode),
        locale: settings.locale == null ? null : Locale(settings.locale!),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: switch (loaded) {
          null => const Scaffold(),
          _ when settings.onboardingDone => const HomeShell(),
          _ => const OnboardingScreen(),
        },
      ),
    );
  }
}
