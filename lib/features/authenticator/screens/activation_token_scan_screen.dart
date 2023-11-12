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
  void onDetect(BarcodeCapture barcode, BuildContext context) async {
    String value = barcode.barcodes.firstOrNull?.displayValue ?? '';
    var model = Provider.of<AuthenticatorModel>(context, listen: false);
    if (model.isLoading) {
      return;
    }
    await model.setup(value);

    if (!context.mounted) return;

    if (model.status == AuthenticatorStatus.ready) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Einrichtung erfolgreich'),
          backgroundColor: Colors.greenAccent.shade700,
          showCloseIcon: false));
      Navigator.of(context).pop();
      return;
    }
    if (model.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(model.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          showCloseIcon: true,
          duration: const Duration(milliseconds: 4000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 230,
      height: 230,
    );

    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  detectionTimeoutMs: 4000,
                  formats: const [BarcodeFormat.qrCode],
                  autoStart: true,
                  facing: CameraFacing.back,
                  torchEnabled: false,
                  cameraResolution: const Size(1920, 2560),
                ),
                onDetect: (barcode) => onDetect(barcode, context),
                scanWindow: scanWindow,
                fit: BoxFit.contain,
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
                          padding: EdgeInsets.only(bottom: 40),
                          child: Text(
                              'Platziere den QR-Code innheralb des Rechtecks',
                              style: TextStyle(color: Colors.white)),
                        ))
                  ],
                ),
              if (model.isLoading) _loadingOverlay(),
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
