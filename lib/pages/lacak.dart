import 'package:flutter/material.dart';
import 'package:dst_mk2/services/mqtt.dart';
import 'package:dst_mk2/pages/gps.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late MQTTClientWrapper mqttClient;

  @override
  void initState() {
    super.initState();
    mqttClient = MQTTClientWrapper(onMessageReceived: (msg) {
      debugPrint("[MQTT] Message received: $msg");
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
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: const Text(
          'Lacak',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => _showAddDeviceDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E66),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: const [
                    Text(
                      "Belum ada perangkat yang terhubung",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    SizedBox(height: 12),
                    Divider(color: Colors.white54, indent: 32, endIndent: 32),
                    SizedBox(height: 12),
                    Icon(Icons.add_circle, color: Color(0xFF21A8DD), size: 48),
                    SizedBox(height: 8),
                    Text(
                      "Tambah Perangkat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Nama Perangkat"),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(hintText: "Kode Tracker"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                final isValid = await mqttClient.checkTopicExists(code);

                if (isValid) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.close),
                          ),
                          const Icon(Icons.check_circle,
                              size: 60, color: Colors.green),
                          const SizedBox(height: 12),
                          const Text("Yeay :)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text("Perangkat telah berhasil ditambahkan"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GpsPage(
                                    trackerName: nameController.text.trim(),
                                    trackerTopic: codeController.text.trim(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21A8DD),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text("Lacak",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kode tracker tidak ditemukan"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21A8DD),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Hubungkan",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
