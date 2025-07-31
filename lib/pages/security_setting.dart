import 'package:flutter/material.dart';

class SecuritySettingPage extends StatelessWidget {
  const SecuritySettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E66),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Pengaturan Keamanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            title: const Text("Ubah Kata Sandi"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/verif');

              if (result == true && context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 6,
                      duration: Duration(seconds: 2),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kata sandi berhasil diubah",
                              style: TextStyle(color: Colors.black)),
                          Icon(Icons.check_circle, color: Colors.teal),
                        ],
                      ),
                    ),
                  );
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
