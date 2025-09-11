import 'package:authenticator_app/app/models/ui_message.dart';
import 'package:authenticator_app/app/theme/theme.dart';
import 'package:flutter/material.dart';

SnackBar createSnackbarForMessage(
  UIMessage message,
  BuildContext context, {
  bool showCloseIcon = false,
  Duration duration = const Duration(milliseconds: 4000),
}) {
  var color = switch (message.type) {
    UIMessageType.error => Theme.of(context).colorScheme.errorContainer,
    UIMessageType.warning => CustomTheme.warningColor,
    UIMessageType.success => CustomTheme.successColor,
  };
  return SnackBar(
    content: Text(
      message.text,
      style: TextStyle(
        color: message.type == UIMessageType.error ? Theme.of(context).colorScheme.onErrorContainer : CustomTheme.tertiaryColor,
      ),
    ),
    backgroundColor: color,
    showCloseIcon: showCloseIcon,
    duration: duration,
  );
}