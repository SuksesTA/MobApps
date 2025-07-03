import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dst_mk2/services/mqtt.dart';

class GpsPage extends StatefulWidget {
  final String trackerName;
  final String trackerTopic;

  const GpsPage({
    super.key,
    required this.trackerName,
    required this.trackerTopic,
  });

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  late GoogleMapController mapController;
  LatLng currentPosition = const LatLng(-6.200000, 106.816666);

  String temperature = '-';
  String humidity = '-';
  String accX = '-';
  String accY = '-';
  String accZ = '-';
  String speed = '-';
  String condition = '-';

  @override
  void initState() {
    super.initState();
    final mqttClient = MQTTClientWrapper(onMessageReceived: _handleMessage);
    mqttClient.subscribeToTopic(widget.trackerTopic);
  }

  void _handleMessage(String message) {
    try {
      final parts = message.split(',');
      if (parts.length >= 9) {
        setState(() {
          currentPosition =
              LatLng(double.parse(parts[2]), double.parse(parts[3]));
          temperature = parts[4];
          humidity = parts[5];
          accX = parts[6];
          accY = parts[7];
          accZ = parts[8];
          speed = parts[9];
          //condition = parts[8];
        });
      } else {
        debugPrint("[GPSPage] Data kurang lengkap: $message");
      }
    } catch (e) {
      debugPrint("[GPSPage] Error parsing message: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: Stack(
        children: [
          // Google Map Fullscreen
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("tracker"),
                  position: currentPosition,
                ),
              },
            ),
          ),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: const Color(0xFF2C3E66),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.trackerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info Panel di bawah
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoTile("Suhu", "$temperature°C"),
                      _infoTile("Kelembaban", "$humidity%"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoTile("Akselerasi X", accX),
                      _infoTile("Akselerasi Y", accY),
                      _infoTile("Akselerasi Z", accZ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoTile("Kecepatan", speed),
                      _infoTile("Kondisi", condition),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
      ],
    );
  }
}
