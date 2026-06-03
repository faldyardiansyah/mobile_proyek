import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String time;
  final String comment;
  final int rating;
  final String? avatar;
  final String? balasanPemilik;

  const ReviewCard({
    super.key,
    required this.name,
    required this.time,
    required this.comment,
    required this.rating,
    this.avatar,
    this.balasanPemilik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + nama + bintang ──
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    avatar != null ? NetworkImage(avatar!) : null,
                backgroundColor: const Color(0xFF007BC2),
                child: avatar == null
                    ? const Icon(Icons.person,
                        size: 20, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1020),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B8794),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15,
                    color: Colors.orange,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Komentar user ──
          Text(
            comment,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF536273),
            ),
          ),

          // ── Balasan pemilik (tampil kalau ada) ──
          if (balasanPemilik != null && balasanPemilik!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDCFF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: Color(0xFF007BC2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Balasan Pemilik",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF007BC2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balasanPemilik!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}