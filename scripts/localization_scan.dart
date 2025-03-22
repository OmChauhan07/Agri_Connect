import 'dart:io';
import 'dart:convert';

/// A simple utility to scan Flutter codebase for potentially hardcoded strings
/// that should be localized. This helps identify where localization needs to be
/// applied in an existing codebase.
void main() async {
  // Define the directory to scan
  const String rootDir = '../lib';
  
  // File extensions to scan
  const List<String> extensions = ['.dart'];
  
  // Directories to exclude
  const List<String> excludeDirs = [
    'generated', 
    'l10n', 
    '.dart_tool',
    'build'
  ];
  
  // Patterns that likely indicate a hardcoded string
  final List<RegExp> patterns = [
    // Common Text widget patterns
    RegExp(r'Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    RegExp(r'const\s+Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    
    // AppBar titles
    RegExp(r'title\s*:\s*(?:const\s+)?Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    
    // Labels in navigation items
    RegExp(r'label\s*:\s*[\'"].*?[\'"]\s*[,)]'),
    
    // Hints in TextFields
    RegExp(r'hintText\s*:\s*[\'"].*?[\'"]\s*[,)]'),
    
    // Button text
    RegExp(r'child\s*:\s*(?:const\s+)?Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    
    // SnackBar content
    RegExp(r'content\s*:\s*(?:const\s+)?Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    
    // AlertDialog title/content
    RegExp(r'title\s*:\s*(?:const\s+)?Text\(\s*[\'"].*?[\'"]\s*[,)]'),
    RegExp(r'content\s*:\s*(?:const\s+)?Text\(\s*[\'"].*?[\'"]\s*[,)]'),
  ];
  
  // Strings to ignore (like very short strings or debugging/logging strings)
  final Set<String> ignoreStrings = {
    '', ' ', ',', '.', ':', ';', '-', '_', '/', '\\', '(', ')', '[', ']', '{', '}',
    '+', '-', '*', '/', '=', '<', '>', '≤', '≥', '!', '?', '@', '#', '\$', '%', '^', '&',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  };
  
  // Output files
  final outputFile = File('localization_report.md');
  final jsonOutputFile = File('strings_to_localize.json');
  
  // Results storage
  final Map<String, List<HardcodedString>> fileResults = {};
  final Set<String> uniqueStrings = {};
  
  // Scan the directories
  print('🔍 Scanning for hardcoded strings in $rootDir...');
  await scanDirectory(
    Directory(rootDir), 
    extensions, 
    excludeDirs, 
    patterns, 
    ignoreStrings,
    fileResults,
    uniqueStrings,
  );
  
  // Generate the report
  await generateReport(outputFile, fileResults);
  
  // Generate JSON with unique strings for ARB file
  await generateJsonOutput(jsonOutputFile, uniqueStrings);
  
  print('✅ Scan complete!');
  print('📊 Found ${uniqueStrings.length} unique strings in ${fileResults.length} files');
  print('📝 Report saved to ${outputFile.path}');
  print('📝 JSON strings saved to ${jsonOutputFile.path}');
}

Future<void> scanDirectory(
  Directory directory,
  List<String> extensions,
  List<String> excludeDirs,
  List<RegExp> patterns,
  Set<String> ignoreStrings,
  Map<String, List<HardcodedString>> fileResults,
  Set<String> uniqueStrings,
) async {
  try {
    final List<FileSystemEntity> entities = directory.listSync();
    
    for (var entity in entities) {
      // Skip excluded directories
      if (entity is Directory) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        if (!excludeDirs.contains(dirName)) {
          await scanDirectory(
            entity, 
            extensions, 
            excludeDirs, 
            patterns, 
            ignoreStrings,
            fileResults,
            uniqueStrings,
          );
        }
        continue;
      }
      
      // Process only files with specified extensions
      if (entity is File) {
        final String ext = entity.path.substring(entity.path.lastIndexOf('.'));
        if (extensions.contains(ext)) {
          await scanFile(
            entity, 
            patterns, 
            ignoreStrings,
            fileResults,
            uniqueStrings,
          );
        }
      }
    }
  } catch (e) {
    print('Error scanning directory: $e');
  }
}

Future<void> scanFile(
  File file,
  List<RegExp> patterns,
  Set<String> ignoreStrings,
  Map<String, List<HardcodedString>> fileResults,
  Set<String> uniqueStrings,
) async {
  try {
    final String content = await file.readAsString();
    final List<String> lines = content.split('\n');
    final List<HardcodedString> results = [];
    
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      
      for (var pattern in patterns) {
        final matches = pattern.allMatches(line);
        
        for (var match in matches) {
          final String matchedText = match.group(0) ?? '';
          
          // Extract the string content
          final RegExp stringExtractor = RegExp(r'[\'"](.+?)[\'"]');
          final stringMatch = stringExtractor.firstMatch(matchedText);
          
          if (stringMatch != null) {
            final String extractedString = stringMatch.group(1) ?? '';
            
            // Skip if string should be ignored
            if (ignoreStrings.contains(extractedString) || 
                extractedString.length <= 1 ||
                isNumeric(extractedString)) {
              continue;
            }
            
            // Add to results
            results.add(HardcodedString(
              lineNumber: i + 1,
              lineContent: line.trim(),
              stringValue: extractedString,
            ));
            
            // Add to unique strings
            uniqueStrings.add(extractedString);
          }
        }
      }
    }
    
    // Add to file results if any matches found
    if (results.isNotEmpty) {
      fileResults[file.path] = results;
    }
  } catch (e) {
    print('Error processing file ${file.path}: $e');
  }
}

Future<void> generateReport(
  File outputFile,
  Map<String, List<HardcodedString>> fileResults,
) async {
  final StringBuffer buffer = StringBuffer();
  
  buffer.writeln('# Localization Scan Report');
  buffer.writeln();
  buffer.writeln('## Summary');
  buffer.writeln();
  buffer.writeln('- Total files with hardcoded strings: ${fileResults.length}');
  buffer.writeln('- Generated on: ${DateTime.now()}');
  buffer.writeln();
  
  buffer.writeln('## Files to Update');
  buffer.writeln();
  
  // Sort files by path
  final sortedFiles = fileResults.keys.toList()..sort();
  
  for (var filePath in sortedFiles) {
    final results = fileResults[filePath]!;
    final String fileName = filePath.split(Platform.pathSeparator).last;
    
    buffer.writeln('### $fileName');
    buffer.writeln();
    buffer.writeln('File: `$filePath`');
    buffer.writeln();
    buffer.writeln('| Line | String | Context |');
    buffer.writeln('| ---- | ------ | ------- |');
    
    for (var result in results) {
      // Escape pipe characters in the output
      final escapedString = result.stringValue.replaceAll('|', '\\|');
      final escapedContext = result.lineContent.replaceAll('|', '\\|');
      
      buffer.writeln('| ${result.lineNumber} | "$escapedString" | `$escapedContext` |');
    }
    
    buffer.writeln();
  }
  
  buffer.writeln('## Next Steps');
  buffer.writeln();
  buffer.writeln('1. Review each hardcoded string in the report');
  buffer.writeln('2. Add the strings to your localization files (e.g., `app_en.arb`)');
  buffer.writeln('3. Replace the hardcoded strings with localized strings using `loc.stringKey`');
  buffer.writeln('4. Run the test again to verify all strings have been localized');
  
  await outputFile.writeAsString(buffer.toString());
}

Future<void> generateJsonOutput(
  File jsonOutputFile,
  Set<String> uniqueStrings,
) async {
  final Map<String, String> jsonMap = {};
  
  // Convert each string to a potential key-value pair
  for (var str in uniqueStrings) {
    // Generate a camelCase key from the string
    final String key = generateKeyFromString(str);
    jsonMap[key] = str;
  }
  
  // Write to JSON file with indentation
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await jsonOutputFile.writeAsString(encoder.convert(jsonMap));
}

String generateKeyFromString(String input) {
  // Remove special characters and numbers
  final sanitized = input
      .replaceAll(RegExp(r'[^a-zA-Z\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  
  if (sanitized.isEmpty) {
    return 'text${input.hashCode.abs()}';
  }
  
  // Split by spaces
  final words = sanitized.split(' ');
  
  // First word lowercase, rest capitalized
  final firstWord = words.first.toLowerCase();
  final restWords = words.skip(1).map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join('');
  
  return firstWord + restWords;
}

bool isNumeric(String str) {
  if (str.isEmpty) {
    return false;
  }
  return double.tryParse(str) != null;
}

class HardcodedString {
  final int lineNumber;
  final String lineContent;
  final String stringValue;
  
  HardcodedString({
    required this.lineNumber,
    required this.lineContent,
    required this.stringValue,
  });
} 