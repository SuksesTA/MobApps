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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const TrackPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2C3E66),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
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
  String name = '...';
  String? photoUrl;
  bool isLoading = true;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _banners = [
    {
      'image': 'assets/banner_potads.png',
      'url': 'https://potadsjabar.or.id/',
    },
    {
      'image': 'assets/banner_dst.png',
      'url': 'https://youtu.be/miLtPLwo0OE?si=4x_qTNNC65YhM-J7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();

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

  Future<void> _launchWithFallback(BuildContext context, String url) async {
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
            foregroundColor: Colors.white,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg/bg_home.png',
            fit: BoxFit.cover,
          ),
        ),
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
                                      backgroundImage: NetworkImage(photoUrl!),
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 22,
                                      child: Icon(Icons.person,
                                          color: Colors.grey),
                                    ),
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

                    // Card Perangkat
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D5E8A),
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
                        children: [
                          const Text(
                            "Belum ada perangkat yang terhubung",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                              color: Colors.white54, indent: 32, endIndent: 32),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // TODO: Aksi tambah perangkat
                            },
                            child: Column(
                              children: const [
                                Icon(Icons.add_circle_outline,
                                    color: Color(0xFF21A8DD), size: 40),
                                SizedBox(height: 4),
                                Text(
                                  "Tambah Perangkat",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    // Menu dan Banner
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
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
                                  _menuIcon('assets/ikon/tentang_perangkat.png',
                                      "Tentang\nPerangkat", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const TentangPerangkatPage()),
                                    );
                                  }),
                                  _menuIcon('assets/ikon/tentang_kami.png',
                                      "Tentang\nKami", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const TentangKamiPage()),
                                    );
                                  }),
                                  _menuIcon('assets/ikon/atur_perangkat.png',
                                      "Atur\nPerangkat", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const AturPerangkatPage()),
                                    );
                                  }),
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
                                    onPageChanged: (index) {
                                      setState(() => _currentPage = index);
                                    },
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
                                  children:
                                      List.generate(_banners.length, (index) {
                                    return Container(
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
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ],
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
