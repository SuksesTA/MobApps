import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilSettingPage extends StatefulWidget {
  const ProfilSettingPage({super.key});

  @override
  State<ProfilSettingPage> createState() => _ProfilSettingPageState();
}

class _ProfilSettingPageState extends State<ProfilSettingPage> {
  Map<String, String>? userData;
  bool isLoading = true;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userData = {
        'name': doc.data()?['name'] ?? 'Nama tidak tersedia',
        'email': user.email ?? 'Email tidak tersedia'
      };
      profileImageUrl = doc.data()?['photoUrl'];
      isLoading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      try {
        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoUrl': url});

        setState(() {
          profileImageUrl = url;
        });

        showTopSnackBar(context, const Text("Foto profil berhasil diperbarui"));
      } catch (e) {
        showTopSnackBar(context, Text("Gagal mengunggah foto: $e"));
      }
    }
  }

  Future<void> _deleteUserAccount(String email) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .delete();
      await user.delete();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
        showTopSnackBar(
          context,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Akun berhasil dihapus",
                  style: TextStyle(color: Colors.black)),
              Icon(Icons.check_circle, color: Color(0xFF21A8DD)),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showReauthDialog(email);
      } else {
        showTopSnackBar(context, Text("Gagal menghapus akun: ${e.message}"));
      }
    }
  }

  void _showReauthDialog(String email) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Verifikasi Ulang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Masukkan kata sandi untuk menghapus akun $email"),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Lanjutkan"),
            onPressed: () async {
              final password = passwordController.text.trim();
              if (password.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              final cred = EmailAuthProvider.credential(
                  email: email, password: password);

              try {
                await user!.reauthenticateWithCredential(cred);
                Navigator.of(context).pop();
                await _deleteUserAccount(email);
              } catch (e) {
                showTopSnackBar(
                    context, Text("Verifikasi gagal: ${e.toString()}"));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E66),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Pengaturan Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Ubah Gambar Profil'),
                          trailing: CircleAvatar(
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: profileImageUrl == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          onTap: _pickAndUploadImage,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Ubah Nama'),
                          trailing: Text(
                            userData!['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E66),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/edit');
                            await _loadUserInfo();
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Email'),
                          trailing: Text(
                            userData!['email']!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text("Yakin Hapus Akun?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E66))),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("• Akun dan semua data Anda akan dihapus"),
                                Text("• Tidak dapat dibatalkan"),
                              ],
                            ),
                            actionsPadding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: const Text("Batalkan"),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteUserAccount(userData!['email']!);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: const Text("Hapus"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Hapus Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
