import 'package:flutter/material.dart';
import 'package:keycloak_authenticator/api.dart';
import '../dtos/login_attempt_dto.dart';
import 'package:get_it/get_it.dart';

enum AuthenticatorStatus {
  init,
  setup,
  ready,
  verify,
}

class AuthenticatorModel extends ChangeNotifier {
  AuthenticatorModel();

  AuthenticatorStatus status = AuthenticatorStatus.init;
  String? errorMessage;
  bool isLoading = false;
  LoginAttemptDto? loginAttempt;
  final AuthenticatorService _service = GetIt.I<AuthenticatorService>();
  Authenticator? _authenticator;

  Future<void> init() async {
    if (status != AuthenticatorStatus.init) {
      return;
    }
    try {
      _authenticator = await _service.getFirst();
      status = _authenticator != null
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
      _authenticator = await _service.create(activationToken);
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
      await _service.delete(_authenticator!);
    } on Exception catch (e) {
      errorMessage = 'Entfernen fehlgeschlagen';
      isLoading = false;
      notifyListeners();
      return;
    }
    isLoading = false;
    status = AuthenticatorStatus.setup;
    _authenticator = null;
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
      var challenge = await _authenticator!.fetchChallenge();
      if (challenge != null) {
        loginAttempt = LoginAttemptDto(
          browser: challenge.browser,
          ipAddress: challenge.ipAddress,
          loggedInAt:
              DateTime.fromMillisecondsSinceEpoch(challenge.updatedTimestamp),
          os: challenge.os,
          challenge: challenge,
          expiresIn: challenge.expiresIn ?? 60,
        );
        status = AuthenticatorStatus.verify;
      }
    } on Exception catch (e) {
      errorMessage = 'Anfrage fehlgeschlagen';
      isLoading = false;
      loginAttempt = null;
      notifyListeners();
      return;
    }

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
      await _authenticator!.reply(
        challenge: loginAttempt!.challenge,
        granted: granted,
      );
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
