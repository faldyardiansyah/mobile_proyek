import 'package:flutter/material.dart';


class RoomItem extends StatelessWidget {
  final String room;
  final bool available;

  const RoomItem({
    required this.room,
    required this.available,
  });

  static const Color blue = Color(0xFF007BC2);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: available ? const Color(0xFFEAF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: available ? blue : const Color(0xFFD8E1EA),
          width: available ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            room,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: available ? blue : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Rp 2,0jt/bln",
            style: TextStyle(
              fontSize: 8,
              color: available ? blue : const Color(0xFFB0B8C2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            available ? "Tersedia" : "Terisi",
            style: TextStyle(
              fontSize: 8,
              color: available ? blue : const Color(0xFFB0B8C2),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}