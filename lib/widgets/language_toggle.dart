// lib/widgets/language_toggle.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageToggle extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;

  const LanguageToggle({
    super.key,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final isArabic = localeProvider.locale.languageCode == 'ar';
        
        return TextButton(
          onPressed: () {
            final newLocale = isArabic ? const Locale('en') : const Locale('ar');
            localeProvider.setLocale(newLocale);
          },
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(40, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        );
      },
    );
  }
}
