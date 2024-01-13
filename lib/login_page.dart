
import 'package:flutter/material.dart';
import 'package:uygulama_odevi/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<String> imgs = [
    'assets/login/1.png',
    'assets/login/2.png',
    'assets/login/3.png',
  ];

  List<Map<String, String>> captions = [
    {
      'title': 'Doktorlarla Yan Yana!',
      'sub':
          'Uygulamamız sayesinde, doktorlarla yan yana durun ve doğru teşhisler alın!'
    },
    {
      'title': 'Hastalıkları tanımlamak hiç bu kadar kolay olmamıştı.',
      'sub': 'X-ray görüntüleriyle hızlı ve güvenilir teşhisler alın!'
    },
    {
      'title':
          'Beyin ve kemik hastalıklarını tanımlama konusunda öncü bir uygulama ile tanışın.',
      'sub': ''
    },
  ];

  late PageController controller1;
  late PageController controller2;
  late PageController captionController;
  int position = 0;
  int capPosition = 0;

  @override
  void initState() {
    super.initState();
    controller1 = PageController();
    controller2 = PageController();
    captionController = PageController();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ClipPath(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller1,
              reverse: true,
              children: [
                for (String img in imgs)
                  Image.asset(img,
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: double.infinity),
              ],
            ),
          ),
          ClipPath(
            clipper: ShapeClipper(second: true),
            child: PageView(
              onPageChanged: (val) {
                changeImage(val);
              },
              controller: controller2,
              children: [
                for (String img in imgs)
                  Image.asset(img,
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: double.infinity),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.6, 1.0])),
              height: 270.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < imgs.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: i == position
                                      ? Colors.white
                                      : Colors.white54),
                              height: 10.0,
                              width: i == position ? 20.0 : 10.0),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 160.0,
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: captionController,
                      onPageChanged: (val) {
                        capPosition = val;
                        setState(() {});
                      },
                      children: [
                        for (Map<String, String> caption in captions)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caption['title']!,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[300]),
                              ),
                              SizedBox(height: capPosition == 0 ? 20.0 : 50.0),
                              Text(
                                caption['sub']!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Colors.grey[300]),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: capPosition == 2,
                    child: SizedBox(
                      width: screenWidth,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: const Text('Giriş Yap',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeImage(int val) {
    if (val < position) {
      controller1.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
      captionController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
    } else {
      controller1.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
      captionController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
    }
    position = val;
    setState(() {});
  }
}

class ShapePainter extends CustomPainter {
  final bool second;

  ShapePainter({required this.second});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    Path path = Path();
    if (!second) {
      path.moveTo(0.0, 0.0);
      path.lineTo(size.width, 0.0);
      path.lineTo(size.width, 120.0);
      path.lineTo(0.0, size.height / 2);
    } else {
      path.moveTo(0.0, (size.height / 2) + 20.0);
      path.lineTo(size.width, 140.0);
      path.lineTo(size.width, size.height);
      path.lineTo(0.0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final bool second;

  ShapeClipper({required this.second});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (!second) {
      path.moveTo(0.0, 0.0);
      path.lineTo(size.width, 0.0);
      path.lineTo(size.width, 120.0);
      path.lineTo(0.0, size.height / 2);
    } else {
      path.moveTo(0.0, (size.height / 2) + 10.0);
      path.lineTo(size.width, 130.0);
      path.lineTo(size.width, size.height);
      path.lineTo(0.0, size.height);
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}