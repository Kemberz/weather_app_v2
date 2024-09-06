import 'package:flutter/material.dart';

class BrandedBackground extends StatelessWidget {
  final Widget child;

  const BrandedBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 28, 133, 201),
        ),
        Positioned(
          bottom: -MediaQuery.of(context).size.height / 4,
          right: -MediaQuery.of(context).size.width / 4,
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            height: MediaQuery.of(context).size.height * 2 / 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 51, 153, 219).withOpacity(0.6),
            ),
          ),
        ),
        Positioned(
          top: -MediaQuery.of(context).size.height / 4,
          left: -MediaQuery.of(context).size.width / 4,
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            height: MediaQuery.of(context).size.height * 2 / 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 22, 106, 161).withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 3,
          right: -MediaQuery.of(context).size.width / 12,
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 51, 153, 219).withOpacity(0.3),
            ),
          ),
        ),
        child,
      ],
    );
  }
}