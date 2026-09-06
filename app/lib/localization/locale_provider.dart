// import 'package:flutter/material.dart';

// class LocaleProvider with ChangeNotifier {
//   Locale _locale = const Locale('en'); // default English

//   Locale get locale => _locale;

//   void setLocale(Locale locale) {
//     if (!['en', 'hi'].contains(locale.languageCode)) return;
//     _locale = locale;
//     notifyListeners();
//   }

//   void toggleLocale() {
//     if (_locale.languageCode == 'en') {
//       setLocale(const Locale('hi'));
//     } else {
//       setLocale(const Locale('en'));
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // default English

  static const _prefsKey = 'app_locale';

  Locale get locale => _locale;

  // ✅ Call this once on app start to restore saved language
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);

    if (code != null && ['en', 'hi'].contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  // ✅ Set & persist locale
  Future<void> setLocale(Locale locale) async {
    if (!['en', 'hi'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  // ✅ Toggle EN <-> HI (used by language button)
  Future<void> toggleLocale() async {
    final newCode = _locale.languageCode == 'en' ? 'hi' : 'en';
    await setLocale(Locale(newCode));
  }
}