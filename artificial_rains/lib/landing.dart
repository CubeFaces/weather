import 'package:artificial_rains/main.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> images = [
    "assets/Screenshot_2024-02-10-20-41-28-335_com.aboelezz.artificial_rains.jpg",
    "assets/Screenshot_2024-02-10-20-24-30-269_com.aboelezz.artificial_rains.jpg",
    "assets/Screenshot_2024-02-10-20-30-30-501_com.aboelezz.artificial_rains.jpg",
    "assets/Screenshot_2024-02-10-20-31-54-631_com.aboelezz.artificial_rains.jpg",
    "assets/Screenshot_2024-02-10-20-32-13-830_com.aboelezz.artificial_rains.jpg",
    "assets/Screenshot_2024-02-10-20-32-21-995_com.aboelezz.artificial_rains.jpg",
  ];

  List<String> imageDescriptions = [
    "اختر أكثر من مدينة للمقارنة",
    "تعرف علي قابلية مدن الكويت للأمطار و السحب الصناعيه",
    "تحقق من الحاجة إلي الأمطار",
    "اختر مدينة واحدة لتفاصيل أكثر",
    "معلومات عن طقس المدنية",
    "اكتب ارقام افتراضية لمعرفة إذا كانت مناسبة",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 140, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Center(
          child: Text(
            '!مرحبًا بك في مشروع الأمطار الاصطناعية',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 33, 140, 255), // Start color
              Color.fromARGB(255, 0, 12, 69), // End color
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            images[index],
                            height: 600,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            imageDescriptions[index],
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            textDirection: TextDirection.rtl, // Arabic text
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.grey.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == images.length - 1) {
                    // Last image reached, navigate to MainApp
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  } else {
                    // Go to the next image
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Blue themed button
                ),
                child: Text(
                  _currentPage == images.length - 1 ? 'ابدأ الآن!' : 'التالي',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
