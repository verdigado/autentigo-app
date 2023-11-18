import 'package:flutter/material.dart';
import 'package:gruene_auth_app/app/utils/snackbar_utils.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:provider/provider.dart';

class ActivationTokenInputScreen extends StatefulWidget {
  const ActivationTokenInputScreen({super.key});

  @override
  State<ActivationTokenInputScreen> createState() =>
      _ActivationTokenInputScreenState();
}

class _ActivationTokenInputScreenState
    extends State<ActivationTokenInputScreen> {
  var tokenInput = TextEditingController(text: '');
  var invalidToken = false;
  void Function()? setupHandler;

  bool validTokenInput() {
    return tokenInput.text != 'invalid';
  }

  @override
  void initState() {
    super.initState();
    tokenInput.addListener(() {
      if (tokenInput.text.isEmpty) {
        setState(() {
          setupHandler = null;
          invalidToken = false;
        });
        return;
      }
      if (!validTokenInput()) {
        setState(() {
          setupHandler = null;
          invalidToken = true;
        });
        return;
      }
      setState(() {
        setupHandler = () async {
          var model = Provider.of<AuthenticatorModel>(context, listen: false);
          var message = await model.setup(tokenInput.text);

          if (!context.mounted) return;

          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(createSnackbarForMessage(
              message,
              context,
            ));
          }

          if (model.status == AuthenticatorStatus.ready) {
            Navigator.of(context).pop();
          }
        };
        invalidToken = false;
      });
    });
  }

  @override
  void dispose() {
    tokenInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator Einrichtung'),
      ),
      body: Consumer<AuthenticatorModel>(
        builder: (context, model, child) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Manuelle Eingabe',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const Text(
                'Füge hier die Activation Token URL aus der Grünes Netz Account Konsole ein.'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                controller: tokenInput,
                decoration: const InputDecoration(
                  hintText: 'Aktivierungstoken',
                ),
              ),
            ),
            Opacity(
              opacity: invalidToken ? 1 : 0,
              child: const Text(
                'Das eingegebene Aktivierungstoken ist nicht gültig.',
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: FilledButton.icon(
                    onPressed: setupHandler,
                    icon: model.isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Abschließen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
