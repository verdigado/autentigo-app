import 'package:flutter/material.dart';
import 'package:authenticator_app/app/models/ui_message.dart';

SnackBar createSnackbarForMessage(
  UIMessage message,
  BuildContext context, {
  bool showCloseIcon = false,
  Duration duration = const Duration(milliseconds: 4000),
}) {
  var color = switch (message.type) {
    UIMessageType.error => Theme.of(context).colorScheme.errorContainer,
    UIMessageType.warning => Colors.deepOrange,
    UIMessageType.success => Colors.greenAccent,
  };
  return SnackBar(
    content: Text(message.text),
    backgroundColor: color,
    showCloseIcon: showCloseIcon,
    duration: duration,
  );
}
