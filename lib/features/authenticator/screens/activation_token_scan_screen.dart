import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

// Window scanner widget based on official example
// https://github.com/juliansteenbakker/mobile_scanner/blob/master/example/lib/barcode_scanner_window.dart

class ScanActivationTokenScreen extends StatefulWidget {
  const ScanActivationTokenScreen({
    super.key,
  });

  @override
  State<ScanActivationTokenScreen> createState() =>
      _ScanActivationTokenScreenState();
}

class _ScanActivationTokenScreenState extends State<ScanActivationTokenScreen> {
  late MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    torchEnabled: false,
  );

  void onDetect(BarcodeCapture barcode) {}

  @override
  void initState() {
    super.initState();
    var model = Provider.of<AuthenticatorModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activationtoken Scannen'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context, 'activationToken');
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }
}
