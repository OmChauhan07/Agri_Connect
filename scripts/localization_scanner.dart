import 'dart:io';
import 'dart:convert';

/// A simpler utility to scan Flutter codebase for potentially hardcoded strings
/// that should be localized.
void main() async {
  // Define the directory to scan
  final directory = Directory('../lib');

  // Output files
  final outputFile = File('localization_report.md');
  final jsonOutputFile = File('strings_to_localize.json');

  // Directories to exclude
  final excludeDirectories = ['generated', 'l10n', '.dart_tool', 'build'];

  // Results storage
  final Map<String, List<StringLocation>> fileResults = {};
  final Set<String> uniqueStrings = {};

  print('🔍 Scanning for hardcoded strings...');
  await scanDirectory(
      directory, excludeDirectories, fileResults, uniqueStrings);

  print('✅ Scan complete!');
  print(
      '📊 Found ${uniqueStrings.length} unique strings in ${fileResults.length} files');

  await generateReport(outputFile, fileResults);
  print('📝 Report saved to ${outputFile.path}');

  await generateJsonKeys(jsonOutputFile, uniqueStrings);
  print('📝 JSON keys saved to ${jsonOutputFile.path}');
}

Future<void> scanDirectory(
    Directory directory,
    List<String> excludeDirectories,
    Map<String, List<StringLocation>> results,
    Set<String> uniqueStrings) async {
  try {
    final entities = directory.listSync();

    for (final entity in entities) {
      final name = entity.path.split(Platform.pathSeparator).last;

      if (entity is Directory) {
        if (!excludeDirectories.contains(name)) {
          await scanDirectory(
              entity, excludeDirectories, results, uniqueStrings);
        }
      } else if (entity is File && name.endsWith('.dart')) {
        await scanFile(entity, results, uniqueStrings);
      }
    }
  } catch (e) {
    print('Error scanning directory: $e');
  }
}

Future<void> scanFile(File file, Map<String, List<StringLocation>> results,
    Set<String> uniqueStrings) async {
  try {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final fileResults = <StringLocation>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Simple regex to find strings in quotes
      final singleQuoteMatches = RegExp("'([^']*)'").allMatches(line);
      final doubleQuoteMatches = RegExp('"([^"]*)"').allMatches(line);

      final allMatches = [
        ...singleQuoteMatches,
        ...doubleQuoteMatches,
      ];

      for (final match in allMatches) {
        if (match.groupCount > 0) {
          final string = match.group(1)!;

          // Skip if the string is too short, doesn't contain letters,
          // or is likely not a UI string
          if (string.length <= 1 ||
              !containsLetters(string) ||
              !mightBeUIString(line)) {
            continue;
          }

          fileResults.add(StringLocation(
            lineNumber: i + 1,
            lineContent: line.trim(),
            value: string,
          ));

          uniqueStrings.add(string);
        }
      }
    }

    if (fileResults.isNotEmpty) {
      results[file.path] = fileResults;
    }
  } catch (e) {
    print('Error processing file ${file.path}: $e');
  }
}

bool containsLetters(String input) {
  return RegExp(r'[a-zA-Z]').hasMatch(input);
}

bool mightBeUIString(String line) {
  final uiIndicators = [
    'Text(',
    'title:',
    'label:',
    'hint',
    'child:',
    'content:',
    'AppBar',
    'Button',
    'Dialog',
    'Snack',
    'tooltip:',
  ];

  return uiIndicators.any((indicator) => line.contains(indicator));
}

Future<void> generateReport(
    File outputFile, Map<String, List<StringLocation>> results) async {
  final buffer = StringBuffer();

  buffer.writeln('# Localization Scan Report');
  buffer.writeln();
  buffer.writeln('## Summary');
  buffer.writeln();
  buffer.writeln('- Total files with hardcoded strings: ${results.length}');
  buffer.writeln('- Generated on: ${DateTime.now()}');
  buffer.writeln();

  buffer.writeln('## Files to Update');
  buffer.writeln();

  final sortedFiles = results.keys.toList()..sort();

  for (final filePath in sortedFiles) {
    final fileResults = results[filePath]!;
    final fileName = filePath.split(Platform.pathSeparator).last;

    buffer.writeln('### $fileName');
    buffer.writeln();
    buffer.writeln('File: `$filePath`');
    buffer.writeln();
    buffer.writeln('| Line | String | Context |');
    buffer.writeln('| ---- | ------ | ------- |');

    for (final result in fileResults) {
      final escapedString = result.value.replaceAll('|', '\\|');
      final escapedContext = result.lineContent.replaceAll('|', '\\|');

      buffer.writeln(
          '| ${result.lineNumber} | "$escapedString" | `$escapedContext` |');
    }

    buffer.writeln();
  }

  buffer.writeln('## Next Steps');
  buffer.writeln();
  buffer.writeln('1. Review each hardcoded string in the report');
  buffer.writeln('2. Add the strings to your ARB files (e.g., `app_en.arb`)');
  buffer.writeln(
      '3. Replace the hardcoded strings with localized strings using `loc.stringKey`');
  buffer.writeln(
      '4. Run the test again to verify all strings have been localized');

  await outputFile.writeAsString(buffer.toString());
}

Future<void> generateJsonKeys(
    File jsonOutputFile, Set<String> uniqueStrings) async {
  final jsonMap = <String, String>{};

  for (final string in uniqueStrings) {
    final key = generateKeyFromString(string);
    jsonMap[key] = string;
  }

  final encoder = JsonEncoder.withIndent('  ');
  await jsonOutputFile.writeAsString(encoder.convert(jsonMap));
}

String generateKeyFromString(String input) {
  // Clean the input
  final sanitized = input
      .replaceAll(RegExp(r'[^a-zA-Z\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (sanitized.isEmpty) {
    return 'text${input.hashCode.abs()}';
  }

  // Split into words
  final words = sanitized.split(' ');

  // First word lowercase, rest capitalized
  final firstWord = words.first.toLowerCase();
  final restWords = words.skip(1).map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join('');

  return firstWord + restWords;
}

class StringLocation {
  final int lineNumber;
  final String lineContent;
  final String value;

  StringLocation({
    required this.lineNumber,
    required this.lineContent,
    required this.value,
  });
}
