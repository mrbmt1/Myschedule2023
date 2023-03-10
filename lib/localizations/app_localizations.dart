// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show SynchronousFuture;
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AppLocalizations {
//   AppLocalizations(this.locale);

//   final Locale locale;

//   static AppLocalizations? of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations);
//   }

//   static const LocalizationsDelegate<AppLocalizations> delegate =
//       _AppLocalizationsDelegate();

//   Map<String, String> _localizedStrings = {};

//   Future<Locale> getLocale() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String languageCode = prefs.getString('selectedLanguage') ?? 'vi';
//     return Locale(languageCode);
//   }

//   Future<AppLocalizations> load(Locale locale) async {
//     Locale _locale = locale ?? await getLocale();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String languageCode =
//         prefs.getString('selectedLanguage') ?? _locale.languageCode;
//     String jsonString =
//         await rootBundle.loadString('assets/i18n/${languageCode}.json');
//     Map<String, dynamic> jsonMap = json.decode(jsonString);
//     _localizedStrings =
//         jsonMap.map((key, value) => MapEntry(key, value.toString()));
//     return SynchronousFuture<AppLocalizations>(this);
//   }

//   String? translate(String key) {
//     return _localizedStrings[key];
//   }
// }

// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) {
//     // TODO: Add your supported locales here
//     return true;
//   }

//   @override
//   Future<AppLocalizations> load(Locale locale) async {
//     AppLocalizations localizations = AppLocalizations(locale);
//     await localizations.load(locale);
//     return localizations;
//   }

//   @override
//   bool shouldReload(_AppLocalizationsDelegate old) => false;
// }
