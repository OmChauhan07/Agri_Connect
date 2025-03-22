import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/constants.dart';
import '../../utils/localization_helper.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final supportedLanguages = localeProvider.supportedLanguages;
    final loc = LocalizationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.languageSettings),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.languageSelect,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.languageNote,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: supportedLanguages.length,
              itemBuilder: (context, index) {
                final languageCode = supportedLanguages.keys.elementAt(index);
                final languageName = supportedLanguages.values.elementAt(index);
                final bool isSelected =
                    languageCode == localeProvider.locale.languageCode;

                return ListTile(
                  leading: Radio<String>(
                    value: languageCode,
                    groupValue: localeProvider.locale.languageCode,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLocale(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${loc.commonSuccess}: ${loc.settingsLanguage} ${languageName}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                  title: Text(
                    languageName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  onTap: () {
                    localeProvider.setLocale(languageCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${loc.commonSuccess}: ${loc.settingsLanguage} ${languageName}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
