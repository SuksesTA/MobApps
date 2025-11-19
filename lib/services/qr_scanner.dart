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

  final Map<String, String> trackerKeys = {
    "PukEOu": "key",
    "BNtjEO": "key",
    "YzMtje": "key",
    "zMtjEO": "key",
    "FPuJRV": "key",
    "cbAMtj": "key",
    "zMSVxl": "key",
    "dbAngd": "key",
    "GqieBn": "key",
    "azMtje": "key",
    "aaazMt": "key",
    "SVXYYY": "key",
    "MtjeBn": "key",
    "lFpHqi": "key",
    "HQUWXy": "key",
    "lfcbAn": "key",
    "JriecA": "key",
    "AMSVXY": "key",
    "vkEOuk": "key",
    "iDOTwl": "key",
    "cbaaaa": "key",
    "AMSVxl": "key",
    "NTwlFP": "key",
    "DOuJri": "key",
    "EOTwlf": "key",
  };

  void _handleQR(String? raw) {
    if (_scanned || raw == null) return;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map || !decoded.containsKey("topic")) {
        _showError("QR tidak valid");
        return;
      }

      final topic = decoded["topic"];

      // --- CARI KEY BERDASARKAN TOPIC ---
      if (!trackerKeys.containsKey(topic)) {
        _showError("Tracker tidak dikenal");
        return;
      }

      final key = trackerKeys[topic];

      setState(() => _scanned = true);

      Navigator.pop(context, {
        "topic": topic,
        "key": key,
      });
    } catch (_) {
      _showError("QR tidak dapat dibaca");
    }
  }

  void _showError(String msg) {
    if (!_scanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
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
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              _handleQR(barcode.rawValue);
            },
          ),
          if (_scanned)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}
