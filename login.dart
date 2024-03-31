import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'verify.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flut1/HomeScreen.dart';
TextEditingController countryController = TextEditingController(); // Declare the controller

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static String verify="";

  @override
  State<Login> createState() => _CounterWithUltraGradientsState();
}

class _CounterWithUltraGradientsState extends State<Login> {
  TextEditingController countrycode = TextEditingController();
  var phone="";

  @override
  void initState() {
    // Initialize the controller with default value
    countryController.text = "+91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wrap the image with a circular container
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Add your desired color here
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/bc.jpeg',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "BlackCoffer", // Add your text here
                      style: TextStyle(
                        fontFamily: 'cha', // Add your font family
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),




                SizedBox(
                  height: 120,
                ),
                Text(
                  "Enter Mobile Number",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          controller: countryController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3), // Limit to 3 characters
                          ],
                        ),
                      ),
                      Text(
                        "|",
                        style: TextStyle(fontSize: 33, color: Colors.black),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            phone = value;
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')), // Only allow digits
                            LengthLimitingTextInputFormatter(
                                10), // Limit to 10 characters
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 140,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                    onPressed: () async {
                      String phoneNumber =
                          '${countryController.text}$phone';
                      // Check if the phone number is valid here before verification
                      // For example, you can check its length to ensure it's not empty
                      if (phoneNumber.isNotEmpty) {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phoneNumber,
                          verificationCompleted: (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            Login.verify = verificationId;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyVerify()),
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      } else {
                        // Handle empty phone number
                        print("Phone number is empty");
                      }
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),


        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the homepage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()), // Replace HomePage() with your actual homepage class
                );
              },
              child: FloatingActionButton(
                onPressed: null, // Set onPressed to null since we're using GestureDetector
                child: Icon(Icons.travel_explore, color: Colors.white), // Set icon color to white
                backgroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 8), // Adjust the spacing between the button and the text
            Text(
              "Explore",
              style: TextStyle(color: Colors.black), // Customize text style as needed
            ),
          ],
        ),



        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,


      ),
    );
  }


}



class BackgroundShapes extends StatefulWidget {
  const BackgroundShapes({
    required this.child,
  });

  final Widget child;

  @override
  State<BackgroundShapes> createState() => _BackgroundShapesState();
}

class _BackgroundShapesState extends State<BackgroundShapes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_animation),
                child: Container(),
              );
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener((status) {});
    _controller.dispose();
    super.dispose();
  }
}

class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  const BackgroundPainter(this.animation);

  Offset getOffset(Path path) {
    final pms = path.computeMetrics(forceClosed: false).elementAt(0);
    final length = pms.length;
    final offset = pms.getTangentForOffset(length * animation.value)!.position;
    return offset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.maskFilter = const MaskFilter.blur(
      BlurStyle.normal,
      30,
    );
    drawShape3(canvas, size, paint, Colors.blue);
    drawShape1(canvas, size, paint, Colors.orange);
    drawShape2(canvas, size, paint, Colors.grey);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  void drawShape1(
      Canvas canvas,
      Size size,
      Paint paint,
      Color color,
      ) {
    paint.color = color;
    Path path = Path();

    path.moveTo(size.width, 0);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      -100,
      size.height / 4,
    );

    final offset = getOffset(path);
    canvas.drawCircle(offset, 150, paint);
  }

  void drawShape2(
      Canvas canvas,
      Size size,
      Paint paint,
      Color color,
      ) {
    paint.color = color;
    Path path = Path();

    path.moveTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      size.width * 0.9,
      size.height * 0.9,
    );

    final offset = getOffset(path);
    canvas.drawCircle(offset, 250, paint);
  }

  void drawShape3(
      Canvas canvas,
      Size size,
      Paint paint,
      Color color,
      ) {
    paint.color = color;
    Path path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(
      0,
      size.height,
      size.width / 3,
      size.height / 3,
    );

    final offset = getOffset(path);
    canvas.drawCircle(offset, 250, paint);
  }
}
