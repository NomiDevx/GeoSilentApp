import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppAnimations {
  static Widget loadingAnimation({double size = 100}) {
    return Lottie.asset(
      'assets/animations/loading.json',
      width: size,
      height: size,
    );
  }

  static Widget successAnimation({double size = 150}) {
    return Lottie.asset(
      'assets/animations/success.json',
      width: size,
      height: size,
    );
  }

  static Widget locationAnimation({double size = 200}) {
    return Lottie.asset(
      'assets/animations/location.json',
      width: size,
      height: size,
    );
  }

  static Widget notificationAnimation({double size = 150}) {
    return Lottie.asset(
      'assets/animations/notification.json',
      width: size,
      height: size,
    );
  }

  static Widget profileAnimation({double size = 180}) {
    return Lottie.asset(
      'assets/animations/profile.json',
      width: size,
      height: size,
    );
  }

  // Slide animation for screens
  static Route slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Fade animation
  static Route fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Scale animation
  static Widget scaleAnimation({
    required Widget child,
    required bool show,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedScale(
      scale: show ? 1.0 : 0.95,
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: duration,
        child: child,
      ),
    );
  }
}
