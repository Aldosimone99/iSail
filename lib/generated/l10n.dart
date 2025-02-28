// Questo file viene generato automaticamente dal pacchetto intl_translation.
// Assicurati di eseguire il comando di generazione dopo aver aggiunto nuove traduzioni.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // Add your localized strings here
  String get goodMorning => Intl.message('Buongiorno', name: 'goodMorning');
  String get goodAfternoon => Intl.message('Buon Pomeriggio', name: 'goodAfternoon');
  String get goodEvening => Intl.message('Buonasera', name: 'goodEvening');
  String get search => Intl.message('Cerca', name: 'search');
  String get sort => Intl.message('Ordina', name: 'sort');
  String get delete => Intl.message('Elimina', name: 'delete');
  String get cancel => Intl.message('Annulla', name: 'cancel');
  String get name => Intl.message('Nome', name: 'name');
  String get closestDeadline => Intl.message('Closest Deadline', name: 'closestDeadline');
  String get furthestDeadline => Intl.message('Furthest Deadline', name: 'furthestDeadline');
  String get added => Intl.message('Aggiunto', name: 'added');
  String get confirmDeletion => Intl.message('Conferma Eliminazione', name: 'confirmDeletion');
  String get confirmDeletionMessage => Intl.message('Sei sicuro di voler eliminare questo corso?', name: 'confirmDeletionMessage');
  String get noCoursesAdded => Intl.message('Nessun Corso Aggiunto', name: 'noCoursesAdded');
  String get due => Intl.message('Scadenza', name: 'due');
  String get welcomeTitle => Intl.message('Welcome', name: 'welcomeTitle');
  String get welcomeSubtitle => Intl.message('Inserisci il tuo nome per continuare', name: 'welcomeSubtitle');
  String get continueButton => Intl.message('Continua', name: 'continueButton');
  String get courseExpiring => Intl.message('Course Expiring', name: 'courseExpiring'); // Add this line
  String courseExpiringInDays(String courseName, int daysRemaining) => Intl.message(
    'Il corso "$courseName" scadrà in $daysRemaining giorni. Ricordati di rinnovarlo!',
    name: 'courseExpiringInDays',
    args: [courseName, daysRemaining],
  ); // Add this line

  String courseExpiringInMonths(String courseName, int monthsRemaining) {
    return Intl.message(
      '$courseName scadrà in $monthsRemaining mesi',
      name: 'courseExpiringInMonths',
      args: [courseName, monthsRemaining],
      desc: 'Notification message for courses expiring in months',
    );
  }

  String get homeTitle => Intl.message(
    'SailSafe Home',
    name: 'homeTitle',
    desc: '',
  );
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'), // Add Italian locale
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
