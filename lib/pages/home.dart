import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:dst_mk2/pages/akun.dart';
import 'package:dst_mk2/pages/lacak.dart';
import 'package:dst_mk2/pages/tentang_perangkat.dart';
import 'package:dst_mk2/pages/tentang_kami.dart';
import 'package:dst_mk2/pages/atur_perangkat.dart';
import 'package:dst_mk2/services/mqtt.dart';
import 'package:dst_mk2/services/dekripsi.dart';
import 'package:dst_mk2/services/qr_scanner.dart';
import 'package:dst_mk2/services/status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _handleTabChange(int index) {
    if (index == 1) {
      final tracker = TrackerState();
      if (tracker.isReady) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackerPage(
              trackerName: TrackerState().trackerName!,
              trackerTopic: "hasil/${TrackerState().trackerCode!}",
              aesBase64Key: TrackerState().aesKey!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perangkat belum terhubung."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: _currentIndex == 0 ? const HomeContent() : const AccountPage(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2C3E66),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: _currentIndex,
          onTap: _handleTabChange,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: "Lacak"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final tracker = TrackerState();
  late MQTTClientWrapper mqttClient;
  bool isLoading = true;

  String name = '...';
  String? photoUrl;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _banners = [
    {'image': 'assets/banner_potads.png', 'url': 'https://potadsjabar.or.id/'},
    {
      'image': 'assets/banner_dst.png',
      'url': 'https://youtu.be/miLtPLwo0OE?si=4x_qTNNC65YhM-J7'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    mqttClient = MQTTClientWrapper();
    mqttClient.addListener(_handleEncryptedMessage);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      _currentPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    mqttClient.removeListener(_handleEncryptedMessage);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    setState(() {
      name = data?['name'] ?? 'Tanpa Nama';
      photoUrl = data?['photoUrl'];
      isLoading = false;
    });
  }

  void _handleEncryptedMessage(String topic, String encryptedBase64) async {
    if (topic != "hasil/${tracker.trackerCode}") return;
    final decrypted = await tracker.decryptor?.decryptBase64(encryptedBase64);
    if (decrypted == null) return;
    final parts = decrypted.split(',');
    if (parts.length >= 11) {
      setState(() {
        tracker.battery = parts[1];
        tracker.temperature = parts[4];
        tracker.humidity = parts[5];
        tracker.speed = parts[9];
      });
    }
  }

  void _showAddDeviceDialog(BuildContext context) {
    final nameController = TextEditingController();
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
                  onPressed: () => Navigator.pop(context)),
            ),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Nama Perangkat")),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan QR"),
              onPressed: () async {
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const QRScannerPage()));
                if (result != null &&
                    result is Map &&
                    result.containsKey("topic") &&
                    result.containsKey("key")) {
                  setState(() {
                    tracker.trackerCode = result["topic"];
                    tracker.aesKey = result["key"];
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty ||
                    tracker.trackerCode == null ||
                    tracker.aesKey == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Isi nama dan scan QR terlebih dahulu"),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                final isValid =
                    await mqttClient.checkTopicExists(tracker.trackerCode!);
                if (isValid) {
                  Navigator.pop(context);
                  mqttClient.subscribeToTopic("hasil/${tracker.trackerCode}");
                  tracker.decryptor =
                      AESGCMDecryptor.fromBase64Key(tracker.aesKey!);
                  setState(() {
                    tracker.trackerName = name;
                    tracker.isConnected = true;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Kode tracker tidak ditemukan"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21A8DD)),
              child: const Text("Hubungkan",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWithFallback(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final canLaunchExternally = await canLaunchUrl(uri);
      if (canLaunchExternally) {
        final success =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) _openWebView(context, url);
      } else {
        _openWebView(context, url);
      }
    } catch (_) {
      _openWebView(context, url);
    }
  }

  void _openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
              title: const Text("Tautan"),
              backgroundColor: const Color(0xFF2C3E66),
              foregroundColor: Colors.white),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
          ),
        ),
      ),
    );
  }

  Widget _menuIcon(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF21A8DD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Image.asset('assets/bg/bg_home.png', fit: BoxFit.cover)),
        SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              photoUrl != null
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(photoUrl!))
                                  : const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 22,
                                      child: Icon(Icons.person,
                                          color: Colors.grey)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Halo!",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text(name,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          Image.asset('assets/logo_dst2.png', height: 45),
                        ],
                      ),
                    ),
                    // SENSOR CARD TANPA onTap
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E66),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: tracker.isConnected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.circle,
                                      color: Colors.green, size: 10),
                                  const SizedBox(width: 6),
                                  Text(tracker.trackerCode ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text("• ${tracker.trackerName ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ]),
                                const SizedBox(height: 12),
                                const Text("Baterai",
                                    style: TextStyle(color: Colors.white70)),
                                Text("${tracker.battery}%",
                                    style: const TextStyle(
                                        color: Colors.pinkAccent,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(children: [
                                        const Icon(Icons.speed,
                                            color: Colors.pinkAccent),
                                        Text("${tracker.speed} m/s",
                                            style: const TextStyle(
                                                color: Colors.pinkAccent)),
                                      ]),
                                      Column(children: [
                                        const Icon(Icons.thermostat,
                                            color: Colors.pinkAccent),
                                        Text("${tracker.temperature}°C",
                                            style: const TextStyle(
                                                color: Colors.pinkAccent)),
                                      ]),
                                      Column(children: [
                                        const Icon(Icons.water_drop,
                                            color: Colors.pinkAccent),
                                        Text("${tracker.humidity}%",
                                            style: const TextStyle(
                                                color: Colors.pinkAccent)),
                                      ]),
                                    ])
                              ],
                            )
                          : Column(children: [
                              const Text("Belum ada perangkat yang terhubung",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 10),
                              const Divider(
                                  color: Colors.white54,
                                  indent: 32,
                                  endIndent: 32),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _showAddDeviceDialog(context),
                                child: Column(children: const [
                                  Icon(Icons.add_circle_outline,
                                      color: Color(0xFF21A8DD), size: 40),
                                  SizedBox(height: 4),
                                  Text("Tambah Perangkat",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ]),
                              )
                            ]),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _menuIcon(
                                    'assets/ikon/tentang_perangkat.png',
                                    "Tentang\nPerangkat",
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TentangPerangkatPage(),
                                      ),
                                    ),
                                  ),
                                  _menuIcon(
                                    'assets/ikon/tentang_kami.png',
                                    "Tentang\nKami",
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TentangKamiPage(),
                                      ),
                                    ),
                                  ),
                                  _menuIcon(
                                    'assets/ikon/atur_perangkat.png',
                                    "Detail\nPerangkat",
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AturPerangkatPage(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 160,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _banners.length,
                                    onPageChanged: (index) =>
                                        setState(() => _currentPage = index),
                                    itemBuilder: (context, index) {
                                      final banner = _banners[index];
                                      return GestureDetector(
                                        onTap: () => _launchWithFallback(
                                            context, banner['url']!),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.asset(
                                            banner['image']!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _banners.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentPage == index
                                            ? const Color(0xFF21A8DD)
                                            : Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
