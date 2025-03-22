import 'dart:convert';
import 'dart:io';

/// A utility script to validate ARB files for consistency across languages
/// This ensures that all translations have the same keys and that none are missing
void main() async {
  // Define configuration
  const String arbDirectory = '../assets/translations';
  const String reportPath = 'localization_validation_report.md';

  // Result tracker
  final Map<String, Set<String>> languageKeys = {};
  final Map<String, int> totalKeysPerLanguage = {};
  final Set<String> allKeys = {};
  final Map<String, List<String>> missingKeys = {};
  final Map<String, List<String>> extraKeys = {};

  // Get all ARB files
  final directory = Directory(arbDirectory);
  if (!await directory.exists()) {
    print('❌ Error: Directory $arbDirectory does not exist');
    return;
  }

  final List<FileSystemEntity> files = await directory.list().toList();
  final List<File> arbFiles = files
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  if (arbFiles.isEmpty) {
    print('❌ Error: No ARB files found in $arbDirectory');
    return;
  }

  // Process each ARB file
  print('🔍 Analyzing ${arbFiles.length} ARB files...');
  for (final file in arbFiles) {
    final String languageCode = _getLanguageCodeFromPath(file.path);
    final String content = await file.readAsString();

    try {
      final Map<String, dynamic> json = jsonDecode(content);
      final Set<String> keys = _extractTranslationKeys(json);

      languageKeys[languageCode] = keys;
      totalKeysPerLanguage[languageCode] = keys.length;
      allKeys.addAll(keys);

      print('  📋 $languageCode: ${keys.length} keys found');
    } catch (e) {
      print('❌ Error parsing ${file.path}: $e');
    }
  }

  // Find missing and extra keys
  for (final language in languageKeys.keys) {
    final Set<String> keys = languageKeys[language]!;

    // Find missing keys
    final Set<String> missing = allKeys.difference(keys);
    if (missing.isNotEmpty) {
      missingKeys[language] = missing.toList()..sort();
    }

    // Find if this language has any keys others don't
    for (final otherLang in languageKeys.keys) {
      if (language == otherLang) continue;

      final Set<String> otherKeys = languageKeys[otherLang]!;
      final Set<String> extra = keys.difference(otherKeys);

      if (extra.isNotEmpty) {
        extraKeys.putIfAbsent(language, () => []);
        for (final key in extra) {
          if (!extraKeys[language]!.contains('$key (missing in $otherLang)')) {
            extraKeys[language]!.add('$key (missing in $otherLang)');
          }
        }
      }
    }
  }

  // Generate report
  final StringBuffer report = StringBuffer();
  _generateReport(report, languageKeys, totalKeysPerLanguage, allKeys,
      missingKeys, extraKeys);

  // Save report
  final reportFile = File(reportPath);
  await reportFile.writeAsString(report.toString());

  // Print summary
  print('\n📊 Summary:');
  print('  📝 Total unique keys across all languages: ${allKeys.length}');

  final List<String> languagesWithIssues = [
    ...missingKeys.keys,
    ...extraKeys.keys,
  ].toSet().toList();

  if (languagesWithIssues.isEmpty) {
    print('  ✅ All language files are consistent!');
  } else {
    print(
        '  ⚠️ ${languagesWithIssues.length} languages have consistency issues:');
    for (final language in languagesWithIssues) {
      final missing = missingKeys[language]?.length ?? 0;
      final extra = extraKeys[language]?.length ?? 0;
      print('    - $language: $missing missing, $extra extra keys');
    }
  }

  print('\n📝 Full report saved to: $reportPath');
}

/// Extract the language code from the file path
String _getLanguageCodeFromPath(String path) {
  final RegExp regex = RegExp(r'app_(\w+)\.arb$');
  final match = regex.firstMatch(path);
  if (match != null && match.groupCount >= 1) {
    return match.group(1)!;
  }

  // Fallback: use the filename without extension
  final filename = path.split(Platform.pathSeparator).last;
  return filename.split('.').first;
}

/// Extract translation keys from the ARB JSON
Set<String> _extractTranslationKeys(Map<String, dynamic> json) {
  // Exclude metadata entries that start with '@'
  return json.keys
      .where(
          (key) => !key.startsWith('@') && key != 'locale' && key != '@@locale')
      .toSet();
}

/// Generate the validation report
void _generateReport(
  StringBuffer buffer,
  Map<String, Set<String>> languageKeys,
  Map<String, int> totalKeysPerLanguage,
  Set<String> allKeys,
  Map<String, List<String>> missingKeys,
  Map<String, List<String>> extraKeys,
) {
  buffer.writeln('# Localization Validation Report');
  buffer.writeln();
  buffer.writeln('Generated on: ${DateTime.now()}');
  buffer.writeln();

  // Overview section
  buffer.writeln('## Overview');
  buffer.writeln();
  buffer.writeln('| Language | Total Keys | Status |');
  buffer.writeln('| -------- | ---------- | ------ |');

  final List<String> languages = languageKeys.keys.toList()..sort();
  for (final language in languages) {
    final int keyCount = totalKeysPerLanguage[language] ?? 0;
    final bool hasMissing = missingKeys.containsKey(language);
    final bool hasExtra = extraKeys.containsKey(language);

    String status = '✅ Complete';
    if (hasMissing && hasExtra) {
      status = '⚠️ Missing & Extra Keys';
    } else if (hasMissing) {
      status = '⚠️ Missing Keys';
    } else if (hasExtra) {
      status = '⚠️ Extra Keys';
    }

    buffer.writeln('| $language | $keyCount | $status |');
  }

  buffer.writeln();

  // Missing keys section
  if (missingKeys.isNotEmpty) {
    buffer.writeln('## Missing Keys');
    buffer.writeln();
    buffer.writeln(
        'The following languages are missing keys that exist in other languages:');
    buffer.writeln();

    for (final language in missingKeys.keys.toList()..sort()) {
      buffer.writeln('### $language');
      buffer.writeln();
      buffer.writeln('Missing ${missingKeys[language]!.length} keys:');
      buffer.writeln();
      buffer.writeln('```');
      for (final key in missingKeys[language]!) {
        buffer.writeln(key);
      }
      buffer.writeln('```');
      buffer.writeln();
    }
  }

  // Extra keys section
  if (extraKeys.isNotEmpty) {
    buffer.writeln('## Extra Keys');
    buffer.writeln();
    buffer.writeln(
        'The following languages have keys that are missing in at least one other language:');
    buffer.writeln();

    for (final language in extraKeys.keys.toList()..sort()) {
      buffer.writeln('### $language');
      buffer.writeln();
      buffer.writeln(
          'Has ${extraKeys[language]!.length} keys that are missing in other languages:');
      buffer.writeln();
      buffer.writeln('```');
      for (final key in extraKeys[language]!..sort()) {
        buffer.writeln(key);
      }
      buffer.writeln('```');
      buffer.writeln();
    }
  }

  // Recommendations section
  buffer.writeln('## Recommendations');
  buffer.writeln();

  if (missingKeys.isEmpty && extraKeys.isEmpty) {
    buffer.writeln('✅ All language files are consistent! No action needed.');
  } else {
    buffer.writeln('To ensure consistency across all languages:');
    buffer.writeln();
    buffer.writeln('1. Add the missing keys to each language file.');
    buffer.writeln(
        '2. Review any extra keys to determine if they should be added to all languages or removed.');
    buffer.writeln('3. Run this validation again after making changes.');
    buffer.writeln();
    buffer.writeln(
        '> **Note:** It\'s recommended to keep the same set of keys across all language files, even if some translations are temporarily left in English.');
  }
}
