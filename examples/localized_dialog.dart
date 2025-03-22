import 'package:flutter/material.dart';
import '../lib/utils/localization_helper.dart';

/// A reusable localized dialog component that demonstrates
/// best practices for localization in dialogs
class LocalizedDialogs {
  /// Shows a localized confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String messageKey,
    String? titleKey,
  }) async {
    final loc = LocalizationHelper.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: titleKey != null
            ? Text(LocalizationHelper.getTranslatedText(context, titleKey))
            : Text(loc.commonConfirm),
        content:
            Text(LocalizationHelper.getTranslatedText(context, messageKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
  }

  /// Shows a localized error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String messageKey,
    String? titleKey,
  }) async {
    final loc = LocalizationHelper.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: titleKey != null
            ? Text(LocalizationHelper.getTranslatedText(context, titleKey))
            : Text(loc.commonError),
        content:
            Text(LocalizationHelper.getTranslatedText(context, messageKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
  }

  /// Shows a localized success dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String messageKey,
    String? titleKey,
    VoidCallback? onConfirm,
  }) async {
    final loc = LocalizationHelper.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: titleKey != null
            ? Text(LocalizationHelper.getTranslatedText(context, titleKey))
            : Text(loc.commonSuccess),
        content:
            Text(LocalizationHelper.getTranslatedText(context, messageKey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onConfirm != null) onConfirm();
            },
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
  }

  /// Shows a localized language selection dialog
  static Future<void> showLanguageSelectionDialog({
    required BuildContext context,
    required Map<String, String> supportedLanguages,
    required String currentLanguageCode,
    required Function(String) onLanguageSelected,
  }) async {
    final loc = LocalizationHelper.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.languageSelect),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: supportedLanguages.length,
            itemBuilder: (context, index) {
              final langCode = supportedLanguages.keys.elementAt(index);
              final langName = supportedLanguages.values.elementAt(index);

              return RadioListTile<String>(
                title: Text(langName),
                value: langCode,
                groupValue: currentLanguageCode,
                onChanged: (value) {
                  if (value != null) {
                    onLanguageSelected(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.commonCancel),
          ),
        ],
      ),
    );
  }
}

/// Usage examples:
/// 
/// ```dart
/// // Show a confirmation dialog
/// final bool? confirmed = await LocalizedDialogs.showConfirmationDialog(
///   context: context,
///   titleKey: 'deleteConfirmation',
///   messageKey: 'deleteConfirmationMessage',
/// );
/// 
/// if (confirmed == true) {
///   // User confirmed the action
///   // Proceed with deletion
/// }
/// 
/// // Show an error dialog
/// await LocalizedDialogs.showErrorDialog(
///   context: context,
///   messageKey: 'networkErrorMessage',
/// );
/// 
/// // Show a success dialog
/// await LocalizedDialogs.showSuccessDialog(
///   context: context,
///   messageKey: 'orderPlacedSuccessfully',
///   onConfirm: () {
///     // Navigate to orders screen
///     Navigator.pushNamed(context, AppRoutes.orders);
///   },
/// );
/// 
/// // Show language selection dialog
/// await LocalizedDialogs.showLanguageSelectionDialog(
///   context: context,
///   supportedLanguages: localeProvider.supportedLanguages,
///   currentLanguageCode: localeProvider.locale.languageCode,
///   onLanguageSelected: (langCode) {
///     localeProvider.setLocale(langCode);
///   },
/// );
/// ``` 