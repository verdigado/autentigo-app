import 'dart:ui';

import 'package:authenticator_app/app/utils/snackbar_utils.dart';
import 'package:authenticator_app/features/authenticator/models/authenticator_model.dart';
import 'package:flutter/material.dart';
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
    var message = await model.setup(value);

    if (!context.mounted) return;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        createSnackbarForMessage(
          message,
          context,
        ),
      );
    }
    if (model.status == AuthenticatorStatus.ready) {
      Navigator.of(context).pop();
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
                  color: Colors.red..withValues(alpha: 0.8),
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                ),
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
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
          color: Colors.white..withValues(alpha: 0.0),
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
    double borderWith = 3;
    double edgeLengthPercent = 0.15;

    final backgroundPath = Path()..addRect(Rect.largest);
    var seekerWindow =
        RRect.fromRectAndRadius(scanWindow, const Radius.circular(20));
    final seekerPath = Path()..addRRect(seekerWindow);
    final seekerInnerPath = Path()..addRRect(seekerWindow.deflate(borderWith));

    // draw background overlay with the seeker window cut out
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      seekerInnerPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // draw the seeker border
    double edgeWith = scanWindow.width * edgeLengthPercent;
    double edgeHeight = scanWindow.height * edgeLengthPercent;

    final borderCutoutVertical = Path()
      ..addRect(
        Rect.fromLTWH(
          scanWindow.left + edgeWith,
          scanWindow.top,
          scanWindow.width - 2 * edgeWith,
          scanWindow.height,
        ),
      );
    final borderCutoutHorizontal = Path()
      ..addRect(
        Rect.fromLTWH(
          scanWindow.left,
          scanWindow.top + edgeHeight,
          scanWindow.width,
          scanWindow.height - 2 * edgeHeight,
        ),
      );

    var borderPath = Path.combine(
      PathOperation.difference,
      seekerPath,
      seekerInnerPath,
    );
    borderPath = Path.combine(
        PathOperation.difference, borderPath, borderCutoutVertical,);
    borderPath = Path.combine(
        PathOperation.difference, borderPath, borderCutoutHorizontal,);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
