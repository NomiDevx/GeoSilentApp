import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -30 * _bounceAnimation.value),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/appicon-rebg.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Geo Silent',
                  textStyle: AppTheme.headline1.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                  ),
                  colors: [
                    Colors.white,
                    AppTheme.secondaryColor,
                    Colors.white,
                  ],
                  speed: const Duration(milliseconds: 500),
                ),
              ],
              isRepeatingAnimation: false,
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 10),
            Text(
              'Smart Sound Management',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
