import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GpsPage extends StatefulWidget {
  final String trackerName;
  final String trackerTopic;

  const GpsPage(
      {super.key, required this.trackerName, required this.trackerTopic});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  late GoogleMapController mapController;
  LatLng currentPosition =
      const LatLng(-6.200000, 106.816666); // default Jakarta

  @override
  void initState() {
    super.initState();
    // Inisialisasi logika pengambilan data tracker jika diperlukan
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            width: double.infinity,
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
          Expanded(
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
        ],
      ),
    );
  }
}
