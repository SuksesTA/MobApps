import 'package:flutter/material.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E66),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Tentang Kami'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/foto_kami.png', // gambar berisi 3 orang
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Perkenalkan',
              style: TextStyle(
                color: Color(0xFF21A8DD),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kami merupakan tim pengembang dari DST, dengan terdiri dari:\n'
              '1. Geva Almer Hariri\n'
              '2. Moch Firza Yudistira Meizia\n'
              '3. Mohamad Farrel William Rosyadi\n\n'
              'Kami merupakan mahasiswa semester akhir dari Telkom University.\n'
              'Projek DST merupakan Tugas Akhir yang kami kerjakan. Dalam pengembangan,\n'
              'proyek ini juga bekerja sama dengan Telkomsel dan PIK POTADS.\n\n'
              'Diharapkan dengan DST, orang tua dapat terbantu untuk mengawasi anaknya secara real-time.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Ganti bagian ini dengan logo footer dari aset
            Center(
              child: Image.asset(
                'assets/dst_full.png', // pastikan ini sudah ada di folder assets/
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
