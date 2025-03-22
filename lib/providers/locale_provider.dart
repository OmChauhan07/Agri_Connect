import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  final String _prefsKey = 'app_locale';

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  // Support for English, Hindi, and Gujarati
  static const Map<String, String> _supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'gu': 'ગુજરાતી',
  };

  Map<String, String> get supportedLanguages => _supportedLanguages;

  // Get the current language name for display
  String get currentLanguageName =>
      _supportedLanguages[_locale.languageCode] ?? 'English';

  // Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_prefsKey);

      if (savedLocale != null && _supportedLanguages.containsKey(savedLocale)) {
        _locale = Locale(savedLocale);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  // Set new locale and save to SharedPreferences
  Future<void> setLocale(String languageCode) async {
    if (_supportedLanguages.containsKey(languageCode)) {
      try {
        _locale = Locale(languageCode);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, languageCode);

        notifyListeners();
      } catch (e) {
        debugPrint('Error saving locale: $e');
      }
    }
  }
}
