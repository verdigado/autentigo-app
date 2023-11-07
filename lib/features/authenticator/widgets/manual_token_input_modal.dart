import 'package:flutter/material.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:provider/provider.dart';

class ManualTokenInputModal extends StatefulWidget {
  const ManualTokenInputModal({super.key});

  @override
  State<ManualTokenInputModal> createState() => _ManualTokenInputModalState();
}

class _ManualTokenInputModalState extends State<ManualTokenInputModal> {
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
          model.setup(tokenInput.text).then((val) {
            if (model.status == AuthenticatorStatus.ready) {
              Navigator.of(context).pop();
            }
          });
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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
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
            if (model.errorMessage != null) Text(model.errorMessage!),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            )
          ],
        ),
      ),
    );
  }
}

class ManualTokenInputModal2 extends ModalRoute<void> {
  final void Function(String activationToken)? onInput;

  ManualTokenInputModal2({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    this.onInput,
  });
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.white.withOpacity(1);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          'This is a nice overlay',
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss2'),
        )
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
