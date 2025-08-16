import 'package:authenticator_app/app/models/ui_message.dart';
import 'package:authenticator_app/features/authenticator/dtos/login_attempt_dto.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:keycloak_authenticator/api.dart';

enum AuthenticatorStatus { init, setup, ready, verify }

class AuthenticatorModel extends ChangeNotifier {
  AuthenticatorModel();

  AuthenticatorStatus status = AuthenticatorStatus.init;
  Exception? error;
  bool isLoading = false;
  LoginAttemptDto? loginAttempt;
  final AuthenticatorService _service = GetIt.I<AuthenticatorService>();
  Authenticator? _authenticator;

  Future<UIMessage?> init() async {
    if (status != AuthenticatorStatus.init) {
      return null;
    }
    try {
      _authenticator = await _service.getFirst();
      status = _authenticator != null ? AuthenticatorStatus.ready : AuthenticatorStatus.setup;
    } on Exception catch (err) {
      error = err;
      loginAttempt = null;
      notifyListeners();
      return UIMessage.error(err.toString());
    }
    error = null;
    loginAttempt = null;
    notifyListeners();
    return null;
  }

  Future<UIMessage?> setup(String activationToken) async {
    if (status != AuthenticatorStatus.setup || isLoading) {
      return null;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _authenticator = await _service.create(activationToken);
    } on Exception catch (err) {
      error = err;
      isLoading = false;
      notifyListeners();
      return UIMessage.error(err.toString());
    }
    isLoading = false;
    status = AuthenticatorStatus.ready;
    loginAttempt = null;
    notifyListeners();
    return UIMessage.success('Authenticator eingerichtet');
  }

  Future<UIMessage?> delete() async {
    if (status != AuthenticatorStatus.ready || _authenticator == null) {
      return null;
    }
    try {
      await _service.delete(_authenticator!);
    } on Exception catch (err) {
      return UIMessage.error(err.toString());
    }
    status = AuthenticatorStatus.setup;
    _authenticator = null;
    loginAttempt = null;
    notifyListeners();
    return null;
  }

  Future<UIMessage?> refresh() async {
    if (status != AuthenticatorStatus.ready || isLoading) {
      return null;
    }
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      var challenge = await _authenticator!.fetchChallenge();
      if (challenge != null) {
        loginAttempt = LoginAttemptDto(
          browser: challenge.browser,
          ipAddress: challenge.ipAddress,
          loggedInAt: DateTime.fromMillisecondsSinceEpoch(challenge.updatedTimestamp),
          os: challenge.os,
          challenge: challenge,
          expiresIn: challenge.expiresIn ?? 60,
        );
        status = AuthenticatorStatus.verify;
      }
    } on KeycloakClientException catch (err) {
      UIMessage message;
      if (err.type == KeycloakExceptionType.notRegistered) {
        message = UIMessage.error('Authenticator nicht mehr bekannt');
        try {
          await _service.delete(_authenticator!);
          _authenticator = null;
          status = AuthenticatorStatus.setup;
        } catch (err) {
          //
        }
      } else {
        message = UIMessage.error(err.toString());
      }
      error = err;
      loginAttempt = null;
      isLoading = false;
      notifyListeners();
      return message;
    } on Exception catch (err) {
      error = err;
      loginAttempt = null;
      isLoading = false;
      notifyListeners();
      return UIMessage.error(err.toString());
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> poll() async {
    if (status != AuthenticatorStatus.ready) {
      return true;
    }
    try {
      var challenge = await _authenticator!.fetchChallenge(async: true);
      if (challenge != null) {
        loginAttempt = LoginAttemptDto(
          browser: challenge.browser,
          ipAddress: challenge.ipAddress,
          loggedInAt: DateTime.fromMillisecondsSinceEpoch(challenge.updatedTimestamp),
          os: challenge.os,
          challenge: challenge,
          expiresIn: challenge.expiresIn ?? 60,
        );
        status = AuthenticatorStatus.verify;
        notifyListeners();
        return true;
      }
      return false;
    } on KeycloakClientException catch (e) {
      if (e.type == KeycloakExceptionType.notRegistered) {
        try {
          await _service.delete(_authenticator!);
          _authenticator = null;
          status = AuthenticatorStatus.setup;
        } catch (err) {
          //
        }
      }
      rethrow;
    }
  }

  Future<UIMessage?> sendReply({required bool granted}) async {
    if (status != AuthenticatorStatus.verify || loginAttempt == null || isLoading) {
      return null;
    }
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      await _authenticator!.reply(challenge: loginAttempt!.challenge, granted: granted);
    } on Exception catch (err) {
      error = err;
      isLoading = false;
      notifyListeners();
      return UIMessage.error(err.toString());
    }
    status = AuthenticatorStatus.ready;
    loginAttempt = null;
    isLoading = false;
    notifyListeners();
    return granted ? UIMessage.success('Login bestätigt') : UIMessage.warning('Login abgelehnt');
  }

  UIMessage? idleTimeout() {
    if (status != AuthenticatorStatus.verify || loginAttempt == null || isLoading) {
      return null;
    }
    status = AuthenticatorStatus.ready;
    loginAttempt = null;
    notifyListeners();
    return UIMessage.warning('Login abgelehnt');
  }
}
