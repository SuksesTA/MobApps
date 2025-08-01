import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dst_mk2/services/mqtt.dart';
import 'package:dst_mk2/services/status.dart';
import 'package:dst_mk2/services/dekripsi.dart';
import 'package:intl/intl.dart';

class TrackerPage extends StatefulWidget {
  final String trackerName;
  final String trackerTopic;
  final String aesBase64Key;

  const TrackerPage({
    super.key,
    required this.trackerName,
    required this.trackerTopic,
    required this.aesBase64Key,
  });

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final tracker = TrackerState();
  late GoogleMapController mapController;
  late MQTTClientWrapper mqttClient;

  LatLng currentPosition = const LatLng(-6.91201, 107.63124);
  List<LatLng> pathHistory = [];

  String batre = '-';
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
    tracker.decryptor = AESGCMDecryptor.fromBase64Key(widget.aesBase64Key);
    _initMqtt();

    if (tracker.lastLatLng != null) {
      currentPosition = tracker.lastLatLng!;
      pathHistory.add(currentPosition);
    }

    batre = tracker.battery;
    temperature = tracker.temperature;
    humidity = tracker.humidity;
    accX = tracker.accX;
    accY = tracker.accY;
    accZ = tracker.accZ;
    speed = tracker.speed;
    condition = tracker.condition;
  }

  Future<void> _initMqtt() async {
    mqttClient = MQTTClientWrapper();
    mqttClient.addListener(_handleEncryptedMessage);
    mqttClient.subscribeToTopic(widget.trackerTopic);
  }

  @override
  void dispose() {
    mqttClient.removeListener(_handleEncryptedMessage);
    super.dispose();
  }

  void _handleEncryptedMessage(String topic, String encryptedBase64) async {
    if (topic != widget.trackerTopic) return;

    final decrypted = await tracker.decryptor?.decryptBase64(encryptedBase64);
    if (decrypted == null) {
      _showWarning("Dekripsi gagal atau format salah");
      return;
    }

    final parts = decrypted.split(',');
    if (parts.length >= 11) {
      final lat = double.tryParse(parts[2]);
      final lon = double.tryParse(parts[3]);

      if (lat == null || lon == null) {
        debugPrint("[TrackerPage] Parsing lat/lon gagal");
        _showWarning("Koordinat tidak terbaca");
        return;
      }

      final pos = LatLng(lat, lon);

      tracker.battery = parts[1];
      tracker.temperature = parts[4];
      tracker.humidity = parts[5];
      tracker.accX = parts[6];
      tracker.accY = parts[7];
      tracker.accZ = parts[8];
      tracker.speed = parts[9];
      tracker.condition = parts[10];
      tracker.lastLatLng = pos;
      tracker.lastUpdateTime = DateTime.now();

      setState(() {
        batre = tracker.battery;
        temperature = tracker.temperature;
        humidity = tracker.humidity;
        accX = tracker.accX;
        accY = tracker.accY;
        accZ = tracker.accZ;
        speed = tracker.speed;
        condition = tracker.condition;
        currentPosition = pos;
        pathHistory.add(pos);
        showWarning = false;
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pos, zoom: 17),
        ),
      );
    } else {
      _showWarning("Format data tidak sesuai");
    }
  }

  void _showWarning(String message) {
    debugPrint("[TrackerPage] $message");
    setState(() => showWarning = true);
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
          content: const Text("Yakin ingin memutus koneksi tracker ini?"),
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
                TrackerState().reset();
                Navigator.pop(context, true);
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
        title: Text(
          widget.trackerName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("tracker"),
                  position: currentPosition,
                )
              },
              polylines: pathHistory.length > 1
                  ? {
                      Polyline(
                        polylineId: const PolylineId("path"),
                        color: Colors.blue,
                        width: 4,
                        points: pathHistory,
                      )
                    }
                  : {},
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildSensorCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard() {
    final updateText = tracker.lastUpdateTime != null
        ? DateFormat('HH:mm:ss').format(tracker.lastUpdateTime!)
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showWarning)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
            children: [
              _infoExpanded("Baterai", "$batre%"),
              _infoExpanded("Suhu", "$temperature°C"),
              _infoExpanded("Kelembaban", "$humidity%"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoExpanded("Akselerasi X", accX),
              _infoExpanded("Akselerasi Y", accY),
              _infoExpanded("Akselerasi Z", accZ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoExpanded("Kecepatan", speed),
              _infoExpanded("Kondisi", condition),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Terakhir update",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(updateText,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoExpanded(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
