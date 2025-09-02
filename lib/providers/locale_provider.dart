// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:minddrift/l10n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _override;
  Locale? get override => _override;

  /// Returns either the user‑selected override, or the system locale,
  /// or English if unsupported.
  Locale get locale {
    final sys = ui.PlatformDispatcher.instance.locale;
    final code = _override?.languageCode ?? sys.languageCode;
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == code)) {
      return Locale(code);
    }
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    if (_override == locale) return;
    _override = locale;
    notifyListeners();
    // TODO: persist to SharedPreferences if you want it to survive restarts
  }
}
