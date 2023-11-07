import 'package:flutter/material.dart';
import 'package:keycloak_authenticator/keycloak_authenticator.dart';
import 'login_attempt.dart';
import 'tip_of_the_day_model.dart';
import 'package:get_it/get_it.dart';

enum AuthenticatorStatus {
  init,
  setup,
  ready,
  verify,
}

class AuthenticatorModel extends ChangeNotifier {
  AuthenticatorModel() {
    print('AuthenticatorModel Constructor');
  }

  final List<TipOfTheDayDto> _tips = [
    TipOfTheDayDto(
      title: 'Wolke Decks',
      text:
          'In der Wolke könnt ihr jetzt auch gemeinsam zeitgleich an Decks arbeiten, um eure Projekte zu organisieren.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://wolke.netzbegruenung.de',
      buttonText: 'zur Wolke',
    ),
    TipOfTheDayDto(
      title: 'Für die Grünen',
      text:
          'Kandidierende aufgepasst: Auf fuer-die-gruenen.de könnt ihr euch kostenlos eine eigene Web-Präsenz einrichten.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://fuer-die-gruenen.de',
    ),
    TipOfTheDayDto(
      title: 'Video-Konferzen',
      text:
          'Auf der neuen Seite meet.gruene.de könnt ihr ab sofort Video-Konferenzen starten.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://meet.gruene.de',
    ),
    TipOfTheDayDto(
      title: 'Chatbegrünung',
      text:
          'Ihr habt eine Frage oder ein Problem mit einer grünen Anwendung? In der Chatbegrünung könnt ihr euch im jeweiligen Kanal austauschen und findet Informationen zu Anleitungen und Support.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://chatbegruenung.de',
    ),
    TipOfTheDayDto(
      title: 'Wordpress Sunflower',
      text:
          'Auf sunflower-theme.de könnt ihr kostenlos die grüne Optik für WordPress-Webseiten herunterladen. ',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://sunflower-theme.de',
    ),
    TipOfTheDayDto(
      title: 'Grünlink',
      text:
          'Auf grünlink.de kannst du lange Links auf eine angenehmere Länge verkürzen.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
      url: 'https://grünlink.de',
    ),
    // TipOfTheDayDto(
    //   title: 'QR-Codes',
    //   text: 'Auf service.gruene.de/qrcode/ kannst du Links in QR-Codes umwandeln, die sich mit dem Smartphone und Tablet scannen lassen.',
    //   iconPath: 'assets/images/undraw_articles_wbpb.svg',
    //   url: 'https://service.gruene.de/qrcode/ ',
    // ),
    TipOfTheDayDto(
      title: 'Livestreams',
      text:
          'Mit dem Livestream-Koffer unserer IT-Genossenschaft verdigado könnt ihr unkompliziert Livestreams übertragen.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
    ),
    TipOfTheDayDto(
      title: 'Polls',
      text:
          'Ab sofort kannst du in der Wolke die Polls-App für Umfragen nutzen. Sie wird bald die Termite ablösen, vorerst könnt ihr beide Dienste nutzen.',
      iconPath: 'assets/images/undraw_articles_wbpb.svg',
    ),
  ];
  int _tipIndex = 0;

  TipOfTheDayDto get tipOfTheDay {
    return _tips[_tipIndex];
  }

  void nextTip() {
    _tipIndex = (_tipIndex + 1) % _tips.length;
    notifyListeners();
  }

  AuthenticatorStatus status = AuthenticatorStatus.init;
  String? errorMessage;
  bool isLoading = false;
  LoginAttempt? loginAttempt;
  final AuthenticatorInterface _authenticator =
      GetIt.I<AuthenticatorInterface>();

  Future<void> init() async {
    if (status != AuthenticatorStatus.init) {
      return;
    }
    try {
      status = await _authenticator.isRegistered()
          ? AuthenticatorStatus.ready
          : AuthenticatorStatus.setup;
    } on Exception catch (e) {
      errorMessage = e.toString();
      loginAttempt = null;
      notifyListeners();
      return;
    }
    errorMessage = null;
    loginAttempt = null;
    notifyListeners();
  }

  Future<void> setup(String activationToken) async {
    if (status != AuthenticatorStatus.setup || isLoading) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authenticator.register(activationToken);
    } on Exception catch (e) {
      errorMessage = 'Registerierung fehlgeschlagen:\n${e.toString()}';
      isLoading = false;
      notifyListeners();
      return;
    }
    isLoading = false;
    status = AuthenticatorStatus.ready;

    loginAttempt = null;
    notifyListeners();
  }

  Future<void> unregister() async {
    if (status != AuthenticatorStatus.ready) {
      return;
    }
    try {
      await _authenticator.unregister();
    } on Exception catch (e) {
      errorMessage = 'Unregister fehlgeschlagen';
      isLoading = false;
      notifyListeners();
      return;
    }
    isLoading = false;
    status = AuthenticatorStatus.setup;
    errorMessage = null;
    loginAttempt = null;
    notifyListeners();
  }

  void refresh() async {
    if (status != AuthenticatorStatus.ready || isLoading) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      var challenge = await _authenticator.fetchChallenge();
      loginAttempt = LoginAttempt(
        browser: challenge.browser,
        ipAddress: challenge.ipAddress,
        loggedInAt:
            DateTime.fromMillisecondsSinceEpoch(challenge.updatedTimestamp),
        os: challenge.os,
        challenge: challenge,
      );
    } on Exception catch (e) {
      errorMessage = 'Anfrage fehlgeschlagen';
      isLoading = false;
      notifyListeners();
      return;
    }

    status = AuthenticatorStatus.verify;
    isLoading = false;
    notifyListeners();
  }

  confirm() {
    _sendChallengeResponse(true);
  }

  deny() {
    _sendChallengeResponse(false);
  }

  _sendChallengeResponse(bool granted) async {
    if (status != AuthenticatorStatus.verify ||
        loginAttempt == null ||
        isLoading) {
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (granted) {
        await _authenticator.confirm(loginAttempt!.challenge);
      } else {
        await _authenticator.deny(loginAttempt!.challenge);
      }
    } on Exception catch (e) {
      errorMessage = 'Aktion fehlgeschlagen';
      isLoading = false;
      notifyListeners();
    }
    status = AuthenticatorStatus.ready;
    loginAttempt = null;
    isLoading = false;
    notifyListeners();
  }

  cancel() {
    if (status != AuthenticatorStatus.verify ||
        loginAttempt == null ||
        isLoading) {
      return;
    }
    status = AuthenticatorStatus.ready;
    loginAttempt = null;
    notifyListeners();
  }
}
