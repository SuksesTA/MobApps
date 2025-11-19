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
    "PukEOu": "YD3rEBXKcb4rc67whX13gQ==",
    "BNtjEO": "HvKmhyodofMJxumFnrh8ZA==",
    "YzMtje": "GRebD2fuAQimynNC4tO61w==",
    "zMtjEO": "/Blo/ipC2EU5qPdVdQzNoA==",
    "FPuJRV": "o/J4W28AS62A87Z2GiY4ng==",
    "cbAMtj": "T6LZbIEFvjN6yBD0LZ5WCw==",
    "zMSVxl": "nDpx4Esi+Y1esWAHrDTSGA==",
    "dbAngd": "K2+QzRNHrlqE8TkCfbboJQ==",
    "GqieBn": "/xFjii7UWXDDlg+oTSG+XA==",
    "azMtje": "MIcatOafQt0Fa8xzKJTwPQ==",
    "aaazMt": "asEOVZs49yTQTIGuE265Rw==",
    "SVXYYY": "F+lLkvo2DNdfo3ghzmSNCg==",
    "MtjeBn": "sl0Dj0bJcR7aIJpn804LhQ==",
    "lFpHqi": "iCz2STW9CmfOEZ9SpHsD2A==",
    "HQUWXy": "W5AvrhRjzAjyfTG3SuWZIA==",
    "lfcbAn": "DbhPJnGV6jxSBs+EG9Ngng==",
    "JriecA": "xzRaAY71K2nWSBOgfy2Uvg==",
    "AMSVXY": "IW2L8D5XrALZQXOcBb5oFA==",
    "vkEOuk": "qQ823kyCUbN+GcUglv0qZA==",
    "iDOTwl": "POJXjQmwbxTRhC56zzWQqw==",
    "cbaaaa": "ckkL+CXWnjFkvAelHO9YAw==",
    "AMSVxl": "VhPajEC+KZf0DmOxKnWdCA==",
    "NTwlFP": "7QRrkD/CWBp8phHVLotH+Q==",
    "DOuJri": "Cn/GNZgkvlHSaQOvRo4dcA==",
    "EOTwlf": "ObUC52yBStCVGPwnU5tAbg==",
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
