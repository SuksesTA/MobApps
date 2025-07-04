import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Tracker")),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (BarcodeCapture capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            try {
              final decoded = jsonDecode(code);
              if (decoded is Map &&
                  decoded.containsKey("topic") &&
                  decoded.containsKey("key")) {
                setState(() {
                  _scanned = true;
                });
                Navigator.pop(context, decoded);
              } else {
                showError("QR tidak valid");
              }
            } catch (_) {
              showError("QR tidak dapat dibaca");
            }
          }
        },
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
