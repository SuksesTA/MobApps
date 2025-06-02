import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final _controller = PageController();
  int currentPage = 0;

  final pages = [
    Container(
        color: Colors.grey.shade300), // Ganti dengan gambar atau widget kamu
    Container(color: Colors.grey.shade400),
    Container(color: Colors.grey.shade500),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo di atas
            Padding(
              padding: const EdgeInsets.only(top: 22.0, left: 35.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/logo_dst.png',
                  height: 34,
                ),
              ),
            ),

            // PageView (isi konten)
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: pages[index],
                  ),
                ),
              ),
            ),

            // Dot indicator
            SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: const Color.fromRGBO(52, 69, 107, 1),
                dotColor: Colors.grey.shade300,
              ),
            ),

            SizedBox(height: 20),

            // Tombol Selanjutnya
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage < pages.length - 1) {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Arahkan ke halaman login / home
                      Navigator.pushNamed(context, '/auth');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    currentPage == pages.length - 1 ? "Mulai" : "Selanjutnya",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
