import 'package:flutter/material.dart';

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const FacilityItem({
    required this.icon,
    required this.title,
  });

  static const Color blue = Color(0xFF007BC2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: blue,
            size: 25,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF536273),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}