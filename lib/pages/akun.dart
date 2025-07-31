import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with RouteAware {
  String name = 'Memuat...';
  String email = '';
  String? photoUrl;
  bool isLoading = true;

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
      email = data?['email'] ?? user.email ?? '-';
      photoUrl = data?['photoUrl'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() => isLoading = true);
    _loadUserData(); // Muat ulang saat kembali dari halaman lain
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg/Akun_BG.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      Image.asset('assets/logo_dst2.png', height: 70),
                      const SizedBox(height: 22),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl!) : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF21A8DD),
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              _settingTile(Icons.person, "Pengaturan Profil",
                                  () async {
                                await Navigator.pushNamed(context, '/profile');
                                setState(() => isLoading = true);
                                await _loadUserData();
                                // Data akan otomatis dimuat ulang karena didPopNext
                              }),
                              const Divider(),
                              _settingTile(Icons.lock, "Pengaturan Keamanan",
                                  () async {
                                await Navigator.pushNamed(context, '/security');
                                setState(() => isLoading = true);
                                await _loadUserData();
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Version 2.0.0",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/auth', (route) => false);
                          showTopSnackBar(
                            context,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Anda berhasil keluar",
                                    style: TextStyle(color: Colors.black)),
                                Icon(Icons.check_circle,
                                    color: Color(0xFF21A8DD)),
                              ],
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 130),
                          side: const BorderSide(color: Color(0xFF21A8DD)),
                        ),
                        child: const Text(
                          "Keluar",
                          style: TextStyle(color: Color(0xFF21A8DD)),
                        ),
                      ),
                      const Spacer(),
                      const Text("Bekerja sama dengan :",
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/logo_mitra.png', height: 30),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF21A8DD)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void showTopSnackBar(BuildContext context, Widget content) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: content,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2))
        .then((_) => overlayEntry.remove());
  }
}
