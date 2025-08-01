import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TentangPerangkatPage extends StatelessWidget {
  const TentangPerangkatPage({super.key});

  // Fungsi untuk membuka URL
  void _launchURL() async {
    final Uri url =
        Uri.parse('https://youtu.be/miLtPLwo0OE?si=4x_qTNNC65YhM-J7');
    if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
      throw Exception('Tidak dapat membuka URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tentang Perangkat"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E66),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Apa itu DST?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF21A8DD),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "DST (Down Syndrome Tracker) merupakan perangkat pelacak anak penyandang Down Syndrome untuk membantu orang tua mengawasi dan memantau pola pergerakan anak hiperaktif mereka secara real-time.",
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.asset('assets/ikon/alat.png', height: 150),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bagaimana cara kerja DST?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF21A8DD),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Prosedur dimulai dengan perangkat IoT yang menghasilkan topik dan mengumpulkan data sensor. Data dikirim ke cloud, diproses dengan machine learning untuk memprediksi pola pergerakan, dan ditampilkan secara real-time di aplikasi mobile sesuai topik yang dimasukkan. Untuk lebih lanjut, dapat dilihat dari video Youtube ",
            ),
            GestureDetector(
              onTap: _launchURL,
              child: const Text(
                "berikut",
                style: TextStyle(
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Berapa persen akurasi hasil data DST?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF21A8DD),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Data yang dihasilkan oleh perangkat DST merupakan data yang sesuai dengan standar dari setiap modul sensor yang digunakan. Dengan akurasi prediksi 86% dan dukungan protokol MQTT, DST mampu mengirim data secara real-time dengan keandalan tinggi.",
            ),
            const SizedBox(height: 32),
            Center(
              child: Image.asset('assets/ikon/akurasi.png', height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
