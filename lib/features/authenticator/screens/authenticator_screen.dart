import 'package:authenticator_app/app/constants/app.dart';
import 'package:authenticator_app/app/constants/image_paths.dart';
import 'package:authenticator_app/app/utils/snackbar_utils.dart';
import 'package:authenticator_app/features/authenticator/models/authenticator_model.dart';
import 'package:authenticator_app/features/authenticator/models/tip_of_the_day_model.dart';
import 'package:authenticator_app/features/authenticator/screens/activation_token_input_screen.dart';
import 'package:authenticator_app/features/authenticator/screens/activation_token_scan_screen.dart';
import 'package:authenticator_app/features/authenticator/widgets/tip_of_the_day.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keycloak_authenticator/api.dart';
import 'package:provider/provider.dart';

class AuthenticatorScreen extends StatelessWidget {
  const AuthenticatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticatorModel()),
        ChangeNotifierProvider(create: (context) => TipOfTheDayModel()),
      ],
      child: Consumer<AuthenticatorModel>(
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text(appName, style: TextTheme.of(context).titleLarge),
            actions: [
              if (model.status == AuthenticatorStatus.ready)
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller, Widget? child) => IconButton(
                    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Menü anzeigen',
                  ),
                  menuChildren: [
                    MenuItemButton(onPressed: model.delete, child: const Text('Entfernen')),
                  ],
                ),
            ],
          ),
          body: Builder(
            builder: (context) => switch (model.status) {
              AuthenticatorStatus.setup => const _SetupView(),
              AuthenticatorStatus.ready => const _ReadyView(),
              AuthenticatorStatus.verify => const _VerifyView(),
              AuthenticatorStatus.init => const _InitView(),
            },
          ),
        ),
      ),
    );
  }
}

class _InitView extends StatefulWidget {
  const _InitView();

  @override
  State<_InitView> createState() => _InitViewState();
}

class _InitViewState extends State<_InitView> {
  @override
  void initState() {
    super.initState();
    var model = Provider.of<AuthenticatorModel>(context, listen: false);
    model.init().then((message) {
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(createSnackbarForMessage(message, context));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text('Einrichtung', style: TextTheme.of(context).titleLarge),
              ),
              Container(
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(180),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SvgPicture.asset(imageUndrawMobileAnalytics, height: 220),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Scanne den Code von deiner Account Konsole'),
              ),
              SizedBox(
                width: 240,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        maintainState: false,
                        builder: (context) => ListenableProvider<AuthenticatorModel>.value(
                          value: model,
                          child: const ActivationTokenScanScreen(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Code Scannen'),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Du kannst nicht scannen?'),
              SizedBox(
                width: 240,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ListenableProvider<AuthenticatorModel>.value(
                          value: model,
                          child: const ActivationTokenInputScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Manuelle Eingabe'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadyView extends StatefulWidget {
  const _ReadyView();

  @override
  State<StatefulWidget> createState() => _ReadyViewState();
}

class _ReadyViewState extends State<_ReadyView> {
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _startLongPolling();
  }

  void _startLongPolling() async {
    var model = Provider.of<AuthenticatorModel>(context, listen: false);
    while (_isPolling) {
      try {
        bool success = await model.poll();
        if (success == true) {
          _isPolling = false;
        }
      } on KeycloakClientException catch (e) {
        if (e.type == KeycloakExceptionType.timeout) {
          continue;
        } else {
          _isPolling = false;
        }
      } on Exception {
        _isPolling = false;
      }
    }
  }

  Future<void> onRefresh(BuildContext context, AuthenticatorModel model) async {
    var message = await model.refresh();
    if (!context.mounted) return;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackbarForMessage(message, context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            children: [
              const SizedBox(width: 260, child: TipOfTheDay()),
              const Padding(padding: EdgeInsets.only(top: 42, bottom: 24), child: Text('Keine Login-Anfragen')),
              SizedBox(
                width: 240,
                child: OutlinedButton.icon(
                  icon: model.isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Aktualisieren'),
                  onPressed: () => onRefresh(context, model),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyView extends StatelessWidget {
  const _VerifyView();

  Future<void> onReply(BuildContext context, AuthenticatorModel model, bool granted) async {
    var message = await model.sendReply(granted: granted);

    if (!context.mounted) return;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackbarForMessage(message, context));
    }
  }

  void onTimeout(BuildContext context, AuthenticatorModel model) {
    var message = model.idleTimeout();

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackbarForMessage(message, context));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ConstrainedBox(
        constraints: BoxConstraints(minWidth: size.width, minHeight: size.height),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24, width: size.width),
              Column(children: [_timer(context, model)]),
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: Text(
                  'Login Verifizieren',
                  style: TextStyle(fontSize: 22, letterSpacing: 1, fontFamily: 'GrueneType'),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text('Prüfe die Angaben für die Login-Anfrage deines Kontos', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 8),
              _loginDetails(model),
              const Spacer(flex: 2),
              FilledButton.icon(
                style: model.isLoading
                    ? ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withAlpha(80)),
                      )
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('Freigeben'),
                onPressed: () => onReply(context, model, true),
              ),
              FilledButton.icon(
                style: model.isLoading
                    ? ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.error.withAlpha(80)),
                      )
                    : ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.error.withAlpha(200)),
                      ),
                icon: const Icon(Icons.close),
                label: const Text('Ablehnen'),
                onPressed: () => onReply(context, model, false),
              ),
              Opacity(
                opacity: model.isLoading ? 1 : 0,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(60, 4, 60, 4),
                  child: LinearProgressIndicator(minHeight: 4, borderRadius: BorderRadius.all(Radius.circular(180))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stack _timer(BuildContext context, AuthenticatorModel model) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 40, color: Theme.of(context).colorScheme.primary..withValues(alpha: 0.5)),
        SizedBox(
          height: 140,
          width: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: 0),
            duration: Duration(seconds: model.loginAttempt!.expiresIn),
            onEnd: () => onTimeout(context, model),
            builder: (context, value, _) => CircularProgressIndicator(value: value, strokeWidth: 5),
          ),
        ),
      ],
    );
  }

  Widget _loginDetails(AuthenticatorModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text('Gerät', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Text(model.loginAttempt!.browser),
        Text(model.loginAttempt!.os),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('IP Adresse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Text(model.loginAttempt!.ipAddress),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text('Zeitpunkt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Text(formatDate(model.loginAttempt!.loggedInAt, [dd, '.', M, '.', yyyy, ', ', HH, ':', nn])),
      ],
    );
  }
}
