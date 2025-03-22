# Language Toggle Integration Guide

This guide provides instructions on integrating language switching capabilities into different screens of your FarmersMarketplace application.

## Prerequisites

- Ensure the `LocaleProvider` is properly set up and registered in the widget tree
- Check that the `assets/translations/` directory contains all required ARB files
- Verify the `flutter_localizations` package is added to your dependencies

## Option 1: Using the LanguageScreen

The simplest way to add language switching is to navigate to the dedicated `LanguageScreen`:

```dart
// Add a button or menu item that navigates to the language screen
IconButton(
  icon: const Icon(Icons.language),
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.languageSettings);
  },
),
```

## Option 2: In-Page Language Switching

For in-page language switching, you can implement a quick language selector:

```dart
Widget buildLanguageSelector(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context);
  final loc = LocalizationHelper.of(context);
  
  return PopupMenuButton<String>(
    icon: const Icon(Icons.language),
    tooltip: loc.settingsLanguage,
    onSelected: (String languageCode) {
      localeProvider.setLocale(languageCode);
    },
    itemBuilder: (BuildContext context) {
      return localeProvider.supportedLanguages.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.value),
              if (localeProvider.locale.languageCode == entry.key)
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        );
      }).toList();
    },
  );
}
```

Then use this widget in your app bar or other appropriate location:

```dart
appBar: AppBar(
  title: Text(loc.appTitle),
  actions: [
    buildLanguageSelector(context),
    // Other action buttons
  ],
),
```

## Option 3: Bottom Sheet Language Selector

For a more prominent UI, you can implement a bottom sheet language selector:

```dart
void showLanguageBottomSheet(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final loc = LocalizationHelper.of(context);
  
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                loc.languageSelect,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...localeProvider.supportedLanguages.entries.map((entry) {
              return ListTile(
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: localeProvider.locale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      localeProvider.setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(entry.value),
                onTap: () {
                  localeProvider.setLocale(entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
```

And call this function from a button:

```dart
TextButton.icon(
  icon: const Icon(Icons.language),
  label: Text(loc.settingsLanguage),
  onPressed: () => showLanguageBottomSheet(context),
),
```

## Option 4: Adding to Settings Screen

If your app already has a settings screen, you can add a language option:

```dart
ListTile(
  leading: const Icon(Icons.language),
  title: Text(loc.settingsLanguage),
  subtitle: Text(localeProvider.currentLanguageName),
  onTap: () {
    Navigator.pushNamed(context, AppRoutes.languageSettings);
  },
),
```

## Best Practices

1. **Provide Visual Feedback**: Always provide visual indication of the currently selected language.

2. **Consistent Access**: Make language switching accessible from the same location across the app.

3. **Save User Preference**: Ensure the selected language is saved and persists across app launches.

4. **Immediate Application**: Apply language changes immediately without requiring app restart.

5. **Test All Languages**: Verify that the UI adapts well to all supported languages, especially for languages that might need more space.

## Example: Adding Language Toggle to App Drawer

```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          loc.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      // Other drawer items
      // ...
      ListTile(
        leading: const Icon(Icons.language),
        title: Text(loc.settingsLanguage),
        subtitle: Text(localeProvider.currentLanguageName),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pushNamed(context, AppRoutes.languageSettings);
        },
      ),
    ],
  ),
)
```

## Troubleshooting

If language changes don't appear to work:

1. Verify that the `LocaleProvider` is properly registered in your widget tree
2. Check that you're calling `notifyListeners()` after changing the locale
3. Ensure that all text widgets are using the localization system
4. Verify that the ARB files contain all the necessary keys

Remember that for the best user experience, language selection should be easily accessible but not intrusive. 