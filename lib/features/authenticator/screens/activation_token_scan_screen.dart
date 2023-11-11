import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ActivationTokenScanScreen extends StatefulWidget {
  const ActivationTokenScanScreen({
    super.key,
  });

  @override
  State<ActivationTokenScanScreen> createState() =>
      _ActivationTokenScanScreenState();
}

class _ActivationTokenScanScreenState extends State<ActivationTokenScanScreen> {
  void onDetect(BarcodeCapture barcode) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('QR Code erkannt'),
      backgroundColor: Colors.indigo,
      showCloseIcon: true,
    ));

    String value = barcode.barcodes.firstOrNull?.displayValue ?? '';
    var model = Provider.of<AuthenticatorModel>(context, listen: false);

    await model.setup(value);
    if (model.status == AuthenticatorStatus.ready) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 220,
      height: 220,
    );

    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates,
                  formats: const [BarcodeFormat.qrCode],
                  autoStart: true,
                  facing: CameraFacing.back,
                  torchEnabled: false,
                  cameraResolution: const Size(1920, 2560),
                ),
                onDetect: onDetect,
                // scanWindow: scanWindow,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                child: Container(
                    color: Colors.red.withOpacity(0.8),
                    height: 40,
                    width: MediaQuery.of(context).size.width),
              ),
              if (!model.isLoading)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _ScannerOverlay(scanWindow),
                    ),
                    const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Text(
                              'Platziere den QR-Code innheralb des Rechtecks',
                              style: TextStyle(color: Colors.white)),
                        ))
                  ],
                ),
              if (model.isLoading) _loadingOverlay(),
              if (model.errorMessage != null) _alertBox(context, model),
            ],
          ),
        );
      },
    );
  }

  BackdropFilter _loadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.0),
        ),
        child: const Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Align _alertBox(BuildContext context, AuthenticatorModel model) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(model.errorMessage!),
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlay extends CustomPainter {
  _ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
