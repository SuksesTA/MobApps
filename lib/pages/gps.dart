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
  late MQTTClientWrapper mqttClient;

  LatLng currentPosition = const LatLng(-6.90963, 107.65029);
  List<LatLng> pathHistory = [];

  String temperature = '-';
  String humidity = '-';
  String accX = '-';
  String accY = '-';
  String accZ = '-';
  String speed = '-';
  String condition = '-';

  bool showWarning = false;

  @override
  void initState() {
    super.initState();

    mqttClient = MQTTClientWrapper(
      onMessageReceived: (topic, message) {
        if (topic == widget.trackerTopic) {
          _handleMessage(message);
        }
      },
    );

    mqttClient.subscribeToTopic(widget.trackerTopic);
  }

  void _handleMessage(String message) {
    try {
      final parts = message.split(',');
      if (parts.length >= 10) {
        final lat = double.parse(parts[2]);
        final lon = double.parse(parts[3]);

        final newPosition = LatLng(lat, lon);

        setState(() {
          currentPosition = newPosition;
          pathHistory.add(newPosition);
          temperature = parts[4];
          humidity = parts[5];
          accX = parts[6];
          accY = parts[7];
          accZ = parts[8];
          speed = parts[9];
          // condition = parts.length > 10 ? parts[10] : '-';
          showWarning = false;
        });

        mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
      } else {
        _handleInvalidData(message);
      }
    } catch (e) {
      _handleInvalidData(message, error: e.toString());
    }
  }

  void _handleInvalidData(String message, {String? error}) {
    debugPrint("[GPSPage] Data tidak valid: $message");
    if (error != null) debugPrint("[GPSPage] Error parsing: $error");

    setState(() {
      showWarning = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _disconnectTracker() {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Putuskan koneksi"),
          content: const Text(
              "Apakah Anda yakin ingin memutus koneksi tracker ini?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                mqttClient.unsubscribeFromTopic(widget.trackerTopic);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child:
                  const Text("Putuskan", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E66),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trackerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.link_off, color: Colors.white),
            tooltip: 'Putuskan koneksi',
            onPressed: _disconnectTracker,
          ),
        ],
      ),
      body: Stack(
        children: [
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
              polylines: {
                Polyline(
                  polylineId: const PolylineId("path"),
                  color: Colors.blue,
                  width: 4,
                  points: pathHistory,
                ),
              },
            ),
          ),
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
                  if (showWarning)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Data tidak valid atau GPS belum aktif",
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
