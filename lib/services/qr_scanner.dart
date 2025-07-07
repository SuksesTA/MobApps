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
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleQR(String? raw) {
    if (_scanned || raw == null) return;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map &&
          decoded.containsKey("topic") &&
          decoded.containsKey("key")) {
        final String topic = decoded["topic"];
        final String key = decoded["key"]; // key diharapkan dalam Base64

        // Validasi opsional: pastikan key adalah Base64
        if (!_isValidBase64(key)) {
          _showError("Format kunci tidak valid (bukan Base64)");
          return;
        }

        setState(() => _scanned = true);
        Navigator.pop(context, {
          "topic": topic,
          "key": key,
        });
      } else {
        _showError("QR tidak valid");
      }
    } catch (_) {
      _showError("QR tidak dapat dibaca");
    }
  }

  bool _isValidBase64(String input) {
    try {
      base64Decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showError(String message) {
    if (!_scanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Tracker")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final barcode = capture.barcodes.first;
              _handleQR(barcode.rawValue);
            },
          ),
          if (_scanned)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
