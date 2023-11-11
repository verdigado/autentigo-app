import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_auth_app/app/constants/image_paths.dart';
import 'package:gruene_auth_app/app/theme/custom_colors.dart';
import 'package:gruene_auth_app/app/widgets/alert_box.dart';
import 'package:gruene_auth_app/app/widgets/barcode_scanner_window.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:gruene_auth_app/features/authenticator/widgets/manual_token_input_modal.dart';
import 'package:gruene_auth_app/features/authenticator/widgets/setup_instructions_modal.dart';
import 'package:gruene_auth_app/features/authenticator/widgets/tip_of_the_day.dart';
import 'package:provider/provider.dart';

class AuthenticatorScreen extends StatefulWidget {
  const AuthenticatorScreen({super.key});

  @override
  State<AuthenticatorScreen> createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends State<AuthenticatorScreen> {
  @override
  void initState() {
    super.initState();
    var model = Provider.of<AuthenticatorModel>(context, listen: false);
    model.init();
  }

  @override
  void dispose() {
    print('Screen Dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grünes Netz Authenticator',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          // IconButton(icon: const Icon(Icons.help), onPressed: () => ())
        ],
      ),
      body: Consumer<AuthenticatorModel>(
        builder: (context, model, child) {
          if (model.status == AuthenticatorStatus.setup) {
            return const _SetupView();
          }
          if (model.status == AuthenticatorStatus.ready) {
            return const _ReadyView();
          }
          if (model.status == AuthenticatorStatus.verify) {
            return const _VerifyView();
          }
          return const SizedBox.shrink();
          // return const AuthenticatorInitView();
        },
      ),
    );
  }
}

class _InitView extends StatelessWidget {
  const _InitView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 8,
            ),
          ),
        )
      ],
    );
  }
}

class _SetupView extends StatefulWidget {
  const _SetupView({super.key});

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  ValueNotifier<String?> _activationToken = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _activationToken.addListener(() {
      // Do something when the counter changes
      print('activation token changed');
      print(_activationToken.value);
      var model = Provider.of<AuthenticatorModel>(context, listen: false);
      if (_activationToken.value != null) {
        model.setup(_activationToken.value!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text('Einrichtung', style: TextStyle(fontSize: 24)),
              ),
              Container(
                width: 260,
                decoration: BoxDecoration(
                  color: CustomColors.himmel.shade500.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(180),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child:
                      SvgPicture.asset(imageUndrawMobileAnalytics, height: 220),
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
                      MaterialPageRoute(
                        builder: (context) => BarcodeScannerWindow(
                          title: 'Scan',
                          onDetect: (String activationToken) {
                            _activationToken.value = activationToken;
                            return true;
                          },
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
                      MaterialPageRoute(
                        builder: (context) => const ManualTokenInputModal(),
                      ),
                    );
                  },
                  child: const Text('Manuelle Eingabe'),
                ),
              ),
              const SizedBox(height: 24),
              if (model.isLoading)
                const SizedBox(
                  height: 64,
                  width: 64,
                  child: CircularProgressIndicator(),
                ),
              if (model.errorMessage != null)
                AlertBox(text: model.errorMessage!),
            ],
          )
        ],
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            children: [
              const SizedBox(width: 260, child: TipOfTheDay()),
              const Padding(
                padding: EdgeInsets.only(top: 42, bottom: 24),
                child: Text('Keine Login-Anfragen'),
              ),
              SizedBox(
                width: 240,
                child: TextButton.icon(
                  icon: model.isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            // color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Aktualisieren'),
                  onPressed: () => model.refresh(),
                ),
              ),
              const SizedBox(height: 450),
              OutlinedButton(
                child: Text('Unregister'),
                onPressed: () async {
                  await model.unregister();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class _VerifyView extends StatelessWidget {
  const _VerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: size.width,
          minHeight: size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24, width: size.width),
              Column(
                children: [
                  _timer(context, model),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: Text(
                  'Login Verifizieren',
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 1,
                    fontFamily: 'GrueneType',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Prüfe die Angaben für die Login-Anfrage deines Kontos',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              _loginDetails(model),
              const Spacer(flex: 2),
              FilledButton.icon(
                style: model.isLoading
                    ? ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(80)),
                      )
                    : null,
                icon: Icon(Icons.check),
                label: Text('Freigeben'),
                onPressed: () => model.confirm(),
              ),
              FilledButton.icon(
                style: model.isLoading
                    ? ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Theme.of(context).colorScheme.error.withAlpha(80)),
                      )
                    : ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Theme.of(context).colorScheme.error.withAlpha(200)),
                      ),
                icon: const Icon(Icons.close),
                label: const Text('Ablehnen'),
                onPressed: () => model.deny(),
              ),
              Opacity(
                opacity: model.isLoading ? 1 : 0,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(60, 4, 60, 4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.all(Radius.circular(180)),
                  ),
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
        Icon(
          Icons.shield_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        SizedBox(
          height: 140,
          width: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: 0),
            duration: Duration(
              seconds: model.loginAttempt!.expiresIn,
            ),
            onEnd: () => model.deny(),
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 5,
            ),
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
          child: Text(
            'Gerät',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(model.loginAttempt!.browser),
        Text(model.loginAttempt!.os),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            'IP Adresse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(model.loginAttempt!.ipAddress),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            'Zeitpunkt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          formatDate(model.loginAttempt!.loggedInAt,
              [dd, '.', M, '.', yyyy, ', ', HH, ':', nn]),
        ),
      ],
    );
  }

  Table loginDetails2(AuthenticatorModel model) {
    return Table(
      children: [
        TableRow(
          children: [
            const TableCell(
              child: Text('Datum'),
            ),
            TableCell(
              child: Text(model.loginAttempt?.loggedInAt.toString() ?? ''),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Text('Browser'),
            ),
            TableCell(
              child: Text(model.loginAttempt?.browser ?? ''),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Text('IPAdress'),
            ),
            TableCell(
              child: Text(model.loginAttempt?.ipAddress ?? ''),
            ),
          ],
        ),
      ],
    );
  }
}
