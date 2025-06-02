import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF2C3E66),
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  Image.asset('assets/logo_dst2.png', height: 70),
                  const SizedBox(height: 16),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text("NAMA PANJANG",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF21A8DD))),
                  const Text("example@gmail.com",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pengaturan
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
                    _settingTile(Icons.person, "Pengaturan Profil", () {
                      Navigator.pushNamed(context, '/profile');
                    }),
                    Divider(),
                    _settingTile(Icons.lock, "Pengaturan Keamanan", () {
                      Navigator.pushNamed(context, '/security');
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
              onPressed: () {
                Navigator.pushNamed(context, '/auth');
                showTopSnackBar(
                  context,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Anda berhasil keluar",
                          style: TextStyle(color: Colors.black)),
                      Icon(Icons.check_circle, color: Color(0xFF21A8DD)),
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

            const Text("Bekerja sama dengan :", style: TextStyle(fontSize: 12)),
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
  Future.delayed(const Duration(seconds: 2)).then((_) => overlayEntry.remove());
}
