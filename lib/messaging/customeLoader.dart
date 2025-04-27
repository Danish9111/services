import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Orange-grey gradient loader
          RotationTransition(
            turns: const AlwaysStoppedAnimation(45 / 360),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Color(0xFF2B2B2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
                  strokeWidth: 2.5,
                  backgroundColor: Colors.deepOrange.withOpacity(0.2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Animated text
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.orangeAccent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
