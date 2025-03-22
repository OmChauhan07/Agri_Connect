# Localization System Documentation

## Overview

This document explains how the internationalization (i18n) and localization (l10n) system works in the FarmersMarketplace app, which supports multiple languages including English, Hindi, and Gujarati.

## Architecture

The localization system consists of several components:

1. **ARB Files**: Translation files in App Resource Bundle (ARB) format.
2. **Flutter l10n Tools**: Flutter's built-in localization generation tools.
3. **LocaleProvider**: A provider class to manage the app's current locale.
4. **LocalizationHelper**: A utility class for easy access to translated strings.

## Translation Files

Translation files are in JSON-based ARB format and are located in `assets/translations/`:

- `app_en.arb` - English translations (base language)
- `app_hi.arb` - Hindi translations
- `app_gu.arb` - Gujarati translations

Each file follows this structure:

```json
{
  "@@locale": "en", // or "hi", "gu"
  "appName": "AgriConnect",
  "commonCancel": "Cancel",
  // More translations...
}
```

## Configuration

The localization system is configured via `l10n.yaml` file:

```yaml
arb-dir: assets/translations
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
```

## Usage

### Switching Languages

The app's language can be changed in the Language Settings screen accessible from the profile settings. The language preference is stored using SharedPreferences and will persist across app restarts.

### Accessing Translations in Code

There are several ways to access translations in your code:

1. **Direct access via AppLocalizations**:

```dart
final localizations = AppLocalizations.of(context)!;
Text(localizations.commonCancel);
```

2. **Using LocalizationHelper**:

```dart
final loc = LocalizationHelper.of(context);
Text(loc.commonCancel);
```

3. **For consistent keys in UI**:

```dart
Text('commonCancel').localize(context);
```

## Adding New Translations

To add new translations:

1. Add the new string to `app_en.arb`:

```json
"newStringKey": "New string value"
```

2. Add the same key to other language files with the translated value:

```json
"newStringKey": "नई स्ट्रिंग वैल्यू" // in app_hi.arb
"newStringKey": "નવી સ્ટ્રિંગ વેલ્યુ" // in app_gu.arb
```

3. Add the key to the LocalizationHelper's getTranslatedText method.

4. Run the following command to regenerate the localization files:

```
flutter gen-l10n
```

## Adding New Languages

To add a new language:

1. Create a new ARB file named `app_<language_code>.arb` in the `assets/translations` directory.
2. Add the language to the `_supportedLanguages` map in the LocaleProvider class.
3. Run `flutter gen-l10n` to regenerate localization files.

## Best Practices

1. Always use the localization system for user-facing strings.
2. Keep the translation keys organized by feature or category.
3. Ensure all translation files have the same keys.
4. Test the app with different languages to ensure proper layout with varying text lengths.
5. Consider cultural differences when designing UI elements.

## Troubleshooting

- If translations aren't showing up, ensure you've run `flutter gen-l10n` after adding new strings.
- If the app crashes with locale-related errors, check that all translation files contain the same keys.
- For issues with specific translations, verify the ARB file format and syntax. 