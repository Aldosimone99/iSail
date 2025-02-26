// GENERATED CODE - DO NOT MODIFY BY HAND
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

  // Add localized strings
  String get welcomeTitle => Intl.message(
        'Welcome to SailSafe',
        name: 'welcomeTitle',
        desc: 'Title for the welcome screen',
      );

  String get welcomeSubtitle => Intl.message(
        'Please enter your name to continue',
        name: 'welcomeSubtitle',
        desc: 'Subtitle for the welcome screen',
      );

  String get name => Intl.message(
        'Name',
        name: 'name',
        desc: 'Label for the name input field',
      );

  String get continueButton => Intl.message(
        'Continue',
        name: 'continueButton',
        desc: 'Text for the continue button',
      );

  String get welcomeBack => Intl.message(
        'Welcome back',
        name: 'welcomeBack',
        desc: 'Welcome back message',
      );

  String get goodMorning => Intl.message(
        'Good Morning',
        name: 'goodMorning',
        desc: 'Morning greeting',
      );

  String get goodAfternoon => Intl.message(
        'Good Afternoon',
        name: 'goodAfternoon',
        desc: 'Afternoon greeting',
      );

  String get goodEvening => Intl.message(
        'Good Evening',
        name: 'goodEvening',
        desc: 'Evening greeting',
      );

  String get sort => Intl.message(
        'Sort',
        name: 'sort',
        desc: 'Sort option',
      );

  String get delete => Intl.message(
        'Delete',
        name: 'delete',
        desc: 'Delete option',
      );

  String get cancel => Intl.message(
        'Cancel',
        name: 'cancel',
        desc: 'Cancel option',
      );

  String get confirmDeletion => Intl.message(
        'Confirm Deletion',
        name: 'confirmDeletion',
        desc: 'Confirm deletion title',
      );

  String get confirmDeletionMessage => Intl.message(
        'Are you sure you want to delete this course?',
        name: 'confirmDeletionMessage',
        desc: 'Confirm deletion message',
      );

  String get search => Intl.message(
        'Search...',
        name: 'search',
        desc: 'Search hint text',
      );

  String get due => Intl.message(
        'Due',
        name: 'due',
        desc: 'Due date label',
      );

  String get noCoursesAdded => Intl.message(
        'No Courses Added',
        name: 'noCoursesAdded',
        desc: 'No courses added message',
      );
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'), // English
      Locale.fromSubtags(languageCode: 'it'), // Italian
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
