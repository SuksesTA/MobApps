import 'package:flutter/material.dart';

class AturPerangkatPage extends StatelessWidget {
  const AturPerangkatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Perangkat"),
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
              "Komponen pada Perangkat DST",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF21A8DD),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.asset('assets/ikon/atur_alat.png'),
            ),
            const SizedBox(height: 24),
            const Text(
              "• Poin A: Terdapat sebuah modul SSD1306 atau OLED untuk menampilkan informasi token ESP32, informasi terhubungnya GPS atau tidak, latitude dan longitude dari perangkat, kecepatan pergerakan dari alat, suhu, dan kelembaban.",
            ),
            const SizedBox(height: 12),
            const Text(
              "• Poin B: Terdapat sebuah modul DHT22 atau sensor suhu yang digunakan untuk mendapatkan informasi mengenai suhu dan kelembaban yang ada di sekitar perangkat.",
            ),
            const SizedBox(height: 12),
            const Text(
              "• Poin C: Merupakan tombol power untuk menghidupkan dan mematikan perangkat.",
            ),
            const SizedBox(height: 12),
            const Text(
              "• Poin D: Merupakan modul GPS dari SIM7600G yang digunakan untuk menangkap sinyal GPS dan mendapatkan informasi latitude dan longitude dari alat.",
            ),
            const SizedBox(height: 12),
            const Text(
              "• Poin E: Merupakan port USB Type-C yang digunakan untuk melakukan pengisian daya baterai pada perangkat.",
            ),
            const SizedBox(height: 12),
            const Text(
              "• Poin F: Terdapat lampu indikator ketika perangkat sedang pengisian daya. Ketika lampu padam, maka baterai telah penuh.",
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
